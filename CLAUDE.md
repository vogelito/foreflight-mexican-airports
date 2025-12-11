# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository generates ForeFlight custom packs for Mexican airports and heliports. It converts the official AFAC (Mexican Civil Aviation Authority) aerodrome Excel database into KML/KMZ format, then packages it into a ForeFlight-compatible custom pack ZIP file.

## Key Commands

### Build the Custom Pack
```bash
ruby script/create_custom_pack.rb
```
This is the main command that:
1. Reads the Excel file from `data/aerodromos-helipuertos-pub-301125-02122025.xlsx`
2. Generates KML files at `data/custom_mexican_airports.kml` and `data/custom_mexican_heliports.kml`
3. Creates KMZ files at `data/custom_mexican_airports.kmz` and `data/custom_mexican_heliports.kmz`
4. Builds the custom pack folder structure in `build_pack/`
5. Packages everything into `FEMPPA-Mexican-Airports-v2.1.zip`

### Generate PNG Icons from SVG
```bash
rsvg-convert -w 80 -h 80 -a -o assets/[icon_name].png assets/[icon_name].svg
```
Or use the batch script:
```bash
./png_generator.sh
```

### Install Dependencies
```bash
gem install roo builder rubyzip
```

## Architecture

### Data Flow
1. **Input**: Excel file (`data/aerodromos-helipuertos-pub-301125-02122025.xlsx`) containing Mexican aerodrome data from AFAC
2. **Processing**: Ruby script parses Excel, translates Spanish to English, converts coordinates/units
3. **KML Generation**: Creates styled placemarks with HTML descriptions for both Airports and Heliports layers
4. **KMZ Packaging**: Bundles KML + icon PNGs into compressed archives (one for each layer)
5. **Custom Pack Creation**: Structures files per ForeFlight specification with manifest.json
6. **Final Output**: ZIP file ready for ForeFlight import

### Icon System
The script uses a **base type + status suffix** naming convention for icons:

**Base Types:**
- `aerodrome` - Standard airports
- `heliport` - Helicopter landing sites (includes variants like boat/platform heliports)
- `seaplane_base` - Water landing facilities
- `takeoff_zone` - Basic takeoff areas

**Status Suffixes:**
- `active` - Fully operational (Status: "VIGENTE")
- `in_permit` - Authorization in process (Status: "EN TRAMITE")
- `inactive` - All other statuses (closed, inoperative, etc.)

Icons are stored as:
- SVG sources: `assets/{base}.svg`
- PNG exports: `assets/{base}_{status}.png`
- KMZ package: `files/{base}_{status}.png` (bundled inside the KMZ)

### Translation Maps
The script contains comprehensive translation dictionaries (lines 17-136 in create_custom_pack.rb) for:
- **Aerodrome types** (AERÓDROMO → Aerodrome, HELIPUERTO → Heliport, HELIPLATAFORMA → Heliplatform, etc.)
- **Operation types** (DIURNO → Daytime, etc.)
- **Service types** (SERVICIO PARTICULAR → Private Service, etc.)
- **Classification types** (TERRESTRE → Land-based, ELEVADO → Elevated, etc.)
- **Surface types** (ASFALTO → Asphalt, TERRACERÍA → Dirt, etc.) - Handles spelling variations
- **Aircraft generic terms** (NO DISPONIBLE → Not Available, ULTRALIGEROS → Ultralight, etc.)
- **Status values** (VIGENTE → Active, EN TRAMITE → In Process, etc.)
- **Date/duration fields** (handles special cases like "PROYECTO", "SIN AUTORIZACIÓN")

**Note on Surface Types**: The surface_type_map includes multiple spelling variations (TERRACERÍA, TERRACERIA, TERRAERIA) to handle inconsistencies in the source data.

### Coordinate Conversion
- Input: DMS (Degrees, Minutes, Seconds) from columns 13-18
- Output: Decimal degrees for KML
- Latitude: North positive (columns 13-15)
- Longitude: West negative, manually negated (columns 16-18)
- Coordinate System: Documented in column 12 (typically WGS 84 or NAD 27)

### Unit Conversion
- Elevation converted from meters to feet using factor 3.28084 (line 104)
- Both units displayed in descriptions
- Runway dimensions kept in meters (as provided by AFAC)

### Runway Information
The AFAC database includes detailed runway data:
- **Orientation**: Two values (columns 19-20) for reciprocal runway headings (e.g., "09/27")
- **Length**: Runway length in meters (column 21)
- **Width**: Runway width in meters (column 22)
- **Surface Type**: Runway surface material (column 23) - translated to English
  - Common types: Asphalt, Dirt (Terracería), Concrete, Grass, Metal
  - Handles mixed surfaces (e.g., "Asphalt and Dirt")

**Note**: The "Critical Aircraft" field was removed from the AFAC database in the November 2025 format.

### Classification and Ownership
- **Classification** (column 8): Aerodrome classification
  - Land-based (TERRESTRE), Elevated (ELEVADO), Surface (SUPERFICIE), etc.
- **Reference Key** (column 9): AFAC standardized category codes
  - Format: "1-A", "2-B", "H-1", "H-2", etc.
- **Owner** (column 10): Owner/permit holder name
  - Individuals, companies, ejidos, or aviation clubs
  - Populated for 99.95% of entries

### KML Structure
Each placemark includes:
- **Identifier**: Excel "DESIGNADOR" column prefixed with "X" (e.g., "XMEX" for Mexico City)
- **StyleUrl**: References icon styles defined in document header
- **Description**: HTML-formatted table with ForeFlight-like styling (40px font for tablet readability)
- **Point**: Decimal coordinates in longitude,latitude,altitude format

### Build Output Structure
```
build_pack/
├── manifest.json              # ForeFlight metadata (dates, version, org name)
└── navdata/
    ├── FEMPPA Apts 11-25.kmz  # Airports layer
    └── FEMPPA Heli 11-25.kmz  # Heliports layer
```

### Manifest Configuration
Located at script/create_custom_pack.rb (around line 698):
- Name: "Mexican Airports"
- Organization: "FEMPPA" (Federación Mexicana de Pilotos y Propietarios de Aeronaves)
- Dates: effectiveDate and expirationDate in format YYYYMMDDTHHMMSS
- Version: Numeric (2.1)
- noShare: Controls sharing permissions

## Important Notes

### Excel Column Mapping (November 2025 Format)
The script expects specific column indices (0-based, starting at row 3):
- 0: File Number (NO. DE EXPEDIENTE)
- 1: Aerodrome Type (TIPO AERÓDROMO)
- 2: Identifier/Designator (DESIGNADOR)
- 3: Name (NOMBRE)
- 4: State (ESTADO)
- 5: Municipality (MUNICIPIO)
- 6: Type of Operation (TIPO DE OPERACIÓN)
- 7: Type of Service (TIPO DE SERVICIO)
- 8: Classification (CLASIFICACION)
- 9: Reference Key (CLAVE DE REFERENCIA)
- 10: Owner (NOMBRE)
- 11: Elevation in meters (ELEV M)
- 12: Coordinate System (SISTEMA)
- 13-15: Latitude DMS
- 16-18: Longitude DMS
- 19: Runway Orientation 1 (ORIENTACION 1A)
- 20: Runway Orientation 2 (ORIENTACION 2A)
- 21: Runway Length (LONGITUD DE PISTA A)
- 22: Runway Width (ANCHO DE PISTA A)
- 23: Surface Type (TIPO DE SUPERFICIE A)
- 24: Issue Date (FECHA DE EXPEDICIÓN)
- 25: Permit/Authorization Duration (DURACIÓN DEL PERMISO/AUTORIZACIÓN)
- 26: Expiration Date (FECHA DE VENCIMIENTO)
- 27: Active? (¿VIGENTE?)
- 28: Status (SITUACIÓN) - **Critical for icon selection**
- 29: Coordination Airport (AEROPUERTO DE CORDINACIÓN)

**Important Changes from Previous Format:**
- Removed columns: AERONAVE CRITICA (Critical Aircraft), MES (Month), AÑO (Year)
- Date columns shifted left (24-26 instead of 25-27)
- Status moved from column 31 to column 28

The status column (28) determines the icon suffix:
- "VIGENTE" → active (green icons)
- "EN TRAMITE" → in_permit (yellow icons)
- All others → inactive (red icons)

### Identifier Handling
- All identifiers are prefixed with "X" (around line 229)
- If identifier is empty, the name is used as fallback (around line 586)
- This is important for ForeFlight's airport lookup functionality

### Data Validation
- Rows with coordinates (0, 0) are skipped
- First two rows of Excel are always skipped as headers
- Geographic boundaries enforced: Latitude 14°-33°N, Longitude 86°-119°W
- Script processes 2,170 aerodrome entries from the November 2025 database

### ForeFlight Integration
The custom pack follows ForeFlight's specification:
- KMZ files must be named descriptively (includes date)
- HTML descriptions use large fonts (40px) for in-flight tablet readability
- Styling mimics ForeFlight's blue/white color scheme (#1e374f header)
- Icons bundled inside KMZ in `files/` directory with relative paths

#### Auto-Zoom Behavior

**Important for users:** ForeFlight automatically zooms to fit all placemarks when a custom layer is toggled on. With 2,000+ Mexican airports, this causes significant zoom-out.

**Solution:** Users can disable this in ForeFlight settings:
- Path: More > Settings > Layer Selector > "Auto-Zoom to Custom Content"
- Toggle OFF to prevent zoom when toggling layers
- This is a ForeFlight setting, not controllable via KML

**Technical Note:** ForeFlight does not support KML elements like `<LookAt>`, `<Camera>`, or `<Region>` that could control view behavior. The auto-zoom is intentional UX design for aviation safety. Users must disable it via the ForeFlight setting if they prefer to maintain their current view.

## Historical Database Archive

Starting with version 2.1, all AFAC source Excel files are preserved in the `afac-sources/` directory for version tracking and historical reference:

- `base-aerodromo-helipuertos-pub-28022025.xlsx` (February 2025 format - 23 columns)
- `aerodromos-helipuertos-pub-300925-01102025.xlsx` (September 2025 format - 33 columns)
- `aerodromos-helipuertos-pub-301125-02122025.xlsx` (November 2025 format - 30 columns)

**Note**: The `data/` directory is used for intermediary build files (KML, KMZ) and should not be used for source file storage. The script currently references the working file from `data/` but all archival copies are in `afac-sources/`.
