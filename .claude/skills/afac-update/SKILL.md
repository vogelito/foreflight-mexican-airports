---
name: afac-update
description: Use when AFAC has published a new aerodrome/heliport Excel database, or the user asks to refresh, update, or rebuild the FEMPPA ForeFlight custom pack with new AFAC data.
---

# AFAC Database Update

Refresh the FEMPPA custom pack from a new AFAC `.xlsx`. The mechanical edits are easy. The schema check is the step that matters: AFAC has changed the column layout several times (23 → 33 → 30 → 33 → 32 columns), and a missed shift silently corrupts airport data that pilots rely on.

## How to run commands here

- Use the scripts in `scripts/` for every spreadsheet or KML check. Do not write inline `ruby -e` code: it triggers permission prompts that allow rules can't silence. If you need a new check, add a script to `scripts/` instead.
- Run one command per Bash call (no `&&`, `;` or pipes chaining different tools), and use the Read tool to view files.
- Never read `~/Downloads` or other folders outside the repo.

## 1. Find the new file

- Use **WebFetch** (not curl) on https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos to find the `.xlsx` link and its publication date. gob.mx serves a JavaScript bot check to curl, for both the page and the file.
- Compare against the newest file in `afac-sources/` (the date is in the filename, `DDMMYY`). If it is the same file, stop and tell the user there is nothing new.
- Give the user the direct `.xlsx` link and ask them to download it in their browser and save it into `afac-sources/`, keeping AFAC's original filename. The spelling changes between releases (`aerodromos-y-helipuertos`, `aerodromo-helipuertos`, `aerodromos-helipuertos-pub-DDMMYY-DDMMYYYY`, …). Wait for them to confirm.
- Check it with `file afac-sources/<new>.xlsx`: it must say `Microsoft Excel 2007+`. If it says HTML, the bot check was saved instead of the spreadsheet.
- Copy it to `data/` with `cp`, since that's the working copy the build script reads.

## 2. Check the schema (do not skip this)

```bash
ruby .claude/skills/afac-update/scripts/headers.rb afac-sources/<previous>.xlsx afac-sources/<new>.xlsx
```

- `SCHEMA: identical` → no parsing changes are needed.
- `SCHEMA CHANGED` → update the `row[N]` indices in `script/create_custom_pack.rb` (around line 273) to match. Status (`SITUACIÓN`) drives icon selection, and the lat/lon DMS columns drive placement, so check those first. Then update the column map in `CLAUDE.md`. Tell the user about the change explicitly.
- Then find category values that are new since the previous release:

  ```bash
  ruby .claude/skills/afac-update/scripts/new_values.rb afac-sources/<previous>.xlsx afac-sources/<new>.xlsx
  ```

  This only shows values that are *new since the previous release*, which is handy for the changelog. The authoritative check is the build's `UNTRANSLATED VALUES` report in step 4, which catches every missing translation, old or new.

  For each new value, check the matching `*_map` at the top of `script/create_custom_pack.rb` (most lookups ignore case) and add an English translation if it's missing. A missing entry doesn't break the build; the value just shows in Spanish. A new status that isn't `VIGENTE` or `EN TRAMITE` automatically gets the grey inactive icon, so a new status that really means active or in process needs a translation that maps it to "Active" or "In Process".

## 3. Bump the version and dates

Decide the new version: previous minor + 0.1, e.g. v2.5.1 → v2.6 (check `git tag` and `CHANGELOG.md`). The manifest `"version"` is a number, so v2.6 is `2.6` and a patch release like v2.5.1 is `2.51`. The KMZ suffix is `MM-YY` of the AFAC publication date.

In `script/create_custom_pack.rb`:

| What | Example |
|------|---------|
| `excel_file` | `'data/<new>.xlsx'` |
| `custom_pack_zip` | `'FEMPPA-Mexican-Airports-v2.5.zip'` |
| manifest `"version"` | `2.5` |
| KMZ names in `FileUtils.cp` | `"FEMPPA Apts 10-26.kmz"`, `"FEMPPA Heli 10-26.kmz"` |

## 4. Build and sanity-check

```bash
ruby script/create_custom_pack.rb
```

The build prints every entry, so its output is long. The last two lines must be:

```
Custom pack ZIP file created successfully: FEMPPA-Mexican-Airports-vX.Y.zip
UNTRANSLATED VALUES: none
```

If it lists untranslated values instead (and exits with status 1), add an English entry for each one to the matching map, then rebuild until the report says `none`. Use `find_rows.rb <xlsx> <col> <text>` to see which entries use a value. For a status, the translation also decides the icon color: it must start with "Active" or "In Process" if AFAC means active or pending, or the entry shows grey.

```bash
ruby .claude/skills/afac-update/scripts/check_build.rb afac-sources/<new>.xlsx XGRN <ids from new_values.rb>
```

- Compare `source data rows` with the previous release (the `CLAUDE.md` "Script processes N entries" line). A swing of more than about 2% suggests a parsing problem, not real-world change. Investigate before continuing.
- The `icons:` line counts placemarks per icon. `_3p` (diamond) icons should total roughly the number of third-party entries (`value_counts.rb <xlsx> 7`).
- For each ID, the KML coordinates must match the source DMS values and the icon must match the status (`VIGENTE…` → `_active`, `EN TRAMITE…` → `_in_permit`, anything else → `_inactive`; `_3p` when the service type includes third parties). Include the IDs of rows with new values. Major airports like `XMEX` are not in this database, so don't use them.

## 5. Update the docs

- `CHANGELOG.md`: add a new top entry, following the format of the previous release (source file, publish date, entry count and net change, KMZ names, ZIP name, schema notes, data source, installation steps).
- `CLAUDE.md`: update the input filename (it appears in several places), the ZIP name, the KMZ names in the build tree, the "Format" heading and change notes, the entry count, and the archive list under "Historical Database Archive".

## 6. Commit

Make one commit titled `Update to vX.Y with <Month Year> AFAC database`. Include the new `afac-sources/` file and leave out the generated ZIP and `build_pack/`.

## 7. Release (only when the user asks)

Releases are GitHub releases with the ZIP attached, matching earlier ones (`gh release view v2.4`):

```bash
git tag vX.Y
git push origin main vX.Y
gh release create vX.Y FEMPPA-Mexican-Airports-vX.Y.zip --title "vX.Y - <Month Year> AFAC Database" --notes "<one-line summary>. See CHANGELOG for full details."
```

## Report back

Tell the user the new version, source filename and publish date, entry count (with net change), whether the schema changed, and the path to the ZIP to distribute.
