---
name: afac-update
description: Use when AFAC has published a new aerodrome/heliport Excel database, or the user asks to refresh, update, or rebuild the FEMPPA ForeFlight custom pack with new AFAC data.
---

# AFAC Database Update

Refresh the FEMPPA custom pack from a new AFAC `.xlsx`. The mechanical edits are easy. The schema check is the step that matters: AFAC has changed the column layout several times (23 → 33 → 30 → 33 → 32 columns), and a missed shift silently corrupts airport data that pilots rely on.

## 1. Find and download the new file

- Fetch https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos and find the `.xlsx` link.
- Compare against the newest file in `afac-sources/` (the date is in the filename, `DDMMYY`). If it is the same file, stop and tell the user there is nothing new.
- Download it with `curl -L -o /tmp/<original-filename> <url>`, then copy it to **both** `afac-sources/` (the archive) and `data/` (the working copy the script reads). Keep AFAC's original filename. It changes spelling between releases (`aerodromos-y-helipuertos`, `aerodromo-helipuertos`, …).

## 2. Check the schema (do not skip this)

```bash
ruby .claude/skills/afac-update/scripts/headers.rb afac-sources/<previous>.xlsx afac-sources/<new>.xlsx
```

- `SCHEMA: identical` → no parsing changes are needed.
- `SCHEMA CHANGED` → update the `row[N]` indices in `script/create_custom_pack.rb` (around line 273) to match. Status (`SITUACIÓN`) drives icon selection, and the lat/lon DMS columns drive placement, so check those first. Then update the column map in `CLAUDE.md`. Tell the user about the change explicitly.
- Also look for new values in the type, surface, and status columns that the translation maps don't cover (the maps are at the top of the script). Untranslated Spanish showing up in the output is the symptom.

## 3. Bump the version and dates

Decide the new version: previous + 0.1 (check `git tag` and `CHANGELOG.md`). The KMZ suffix is `MM-YY` of the AFAC publication date.

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

- The run must finish without errors and produce the new ZIP.
- Compare the entry count with the previous release (in the `CHANGELOG.md` / `CLAUDE.md` "Script processes N entries" line). A swing of more than about 2% suggests a parsing problem, not real-world change. Investigate before continuing.
- Spot-check a well-known entry (for example `XMEX`) in `data/custom_mexican_airports.kml`: its coordinates, status, and runway data should look right.

## 5. Update the docs

- `CHANGELOG.md`: add a new top entry, following the format of the previous release (source file, publish date, entry count and net change, KMZ names, ZIP name, schema notes, data source, installation steps).
- `CLAUDE.md`: update the input filename (it appears in several places), the ZIP name, the KMZ names in the build tree, the "Format" heading and change notes, the entry count, and the archive list under "Historical Database Archive".

## 6. Commit

Make one commit titled `Update to vX.Y with <Month Year> AFAC database`. Include the new `afac-sources/` file and leave out the generated ZIP and `build_pack/`. Ask before tagging (`git tag vX.Y`) or pushing.

## Report back

Tell the user the new version, source filename and publish date, entry count (with net change), whether the schema changed, and the path to the ZIP to distribute.
