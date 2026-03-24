# Changelog

All notable changes to the ForeFlight Mexican Airports Custom Pack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2] - 2026-03-23

### Changed

**Updated to March 2026 AFAC Database**
- Source file: `aerodromos-helipuertos-pub-020326.xlsx` (was `aerodromos-helipuertos-pub-301125-02122025.xlsx`)
- Published: March 2, 2026 (was November 30, 2025)
- Total entries: 2,174 (was 2,170) - net +4 facilities

**KMZ Filenames**
- Updated from "11-25" to "03-26" to reflect March 2026 data
- `FEMPPA Apts 03-26.kmz` (was `FEMPPA Apts 11-25.kmz`)
- `FEMPPA Heli 03-26.kmz` (was `FEMPPA Heli 11-25.kmz`)

**Distribution Package**
- Updated from `FEMPPA-Mexican-Airports-v2.1.zip` to `FEMPPA-Mexican-Airports-v2.2.zip`

### Technical Changes

**Database Schema Revert (33-column format restored)**
- AFAC restored three columns that were absent in the November 2025 format:
  - **AERONAVE CRITICA** (Critical Aircraft) — back at column 24
  - **MES** (Month) — back at column 28
  - **AÑO** (Year) — back at column 29
- Date and status columns shifted right due to restored columns:
  - Issue Date: column 24 → 25
  - Permit Duration: column 25 → 26
  - Expiration Date: column 26 → 27
  - Active?: column 27 → 30
  - **Status (SITUACIÓN): column 28 → 31** (critical for icon color assignment)
  - Coordination Airport: column 29 → 32
- Script updated to handle restored 33-column structure

**Critical Aircraft field restored in placemark descriptions**
- "Critical Aircraft" row re-added to the HTML description table
- Data was available in v2.0 but absent in v2.1 when AFAC removed the column

**New Surface Type Translations (21 added)**
- New combinations and spelling variants appearing in March 2026 data:
  - Asphalt variants: "Asphalt and Dirt", "Asphalt and Grass", "Asphalt and Hydraulic Concrete", "Asphalt and Compacted Tucuruguay", "Compact Asphalt and Dirt"
  - Mixed surfaces: "Mixed: Asphalt and Dirt", "Mixed Concrete", "Mixed: Hydraulic Concrete and Dirt", "Mixed: Concrete and Natural Terrain", "Mixed: Hydraulic Concrete and Asphalt", "Mixed: Concrete 1175m / Dirt 200m"
  - Other: "Flexible Pavement", "Pavement and Dirt", "Cement and Grass", "Compacted Tucuruguay", "Concrete and Compacted Tucuruguay", "Dirt and Asphalt", "Dirt and Grass"

### Data Source

**AFAC (Agencia Federal de Aviación Civil) Aerodrome Database**
- File: `aerodromos-helipuertos-pub-020326.xlsx`
- Published: March 2, 2026
- Entries: 2,174 Mexican facilities
- Columns: 33 (restored from 30 in November 2025 format)
- Source: https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos

### Installation

**Upgrading from a previous version:**
1. In ForeFlight, go to More > Content
2. Find the old FEMPPA pack, swipe left and delete it
3. Download `FEMPPA-Mexican-Airports-v2.2.zip`
4. Transfer to your device and open ForeFlight > More > Content > Import
5. Select the ZIP file to import
6. Toggle layers: Map > Layers > FEMPPA Mexican Airports / FEMPPA Mexican Heliports

> **Note:** ForeFlight does not support in-place pack updates — importing a new version always creates a separate entry. Always delete the old pack first to avoid duplicates.

**Optional:** Disable auto-zoom in More > Settings > Layer Selector > Auto-Zoom to Custom Content

### Historical Database Archive

All AFAC source databases are preserved in the `afac-sources/` directory:
- `base-aerodromo-helipuertos-pub-28022025.xlsx` (February 2025)
- `aerodromos-helipuertos-pub-300925-01102025.xlsx` (September 2025)
- `aerodromos-helipuertos-pub-301125-02122025.xlsx` (November 2025)
- `aerodromos-helipuertos-pub-020326.xlsx` (March 2026)

---

## [2.1] - 2025-12-11

### Changed

**Updated to November 2025 AFAC Database**
- Source file: `aerodromos-helipuertos-pub-301125-02122025.xlsx` (was `aerodromos-helipuertos-pub-300925-01102025.xlsx`)
- Published: November 30, 2025 (was September 30, 2025)
- Total entries: 2,170 (was 2,162) - net +8 facilities
- Major data quality improvements: 99.7% of entries corrected for column alignment issues

**New Facilities Added (15 total)**
- **MAC** - Rancho Mariquita (Tamaulipas) - Aerodrome
- **SAC** - San Antonio (Tabasco) - Aerodrome (spelling corrected from "San António")
- **SUT** - Sunset (Baja California) - Aerodrome
- **PNS** - Pinos Altos (Durango) - Aerodrome
- **ZSOL** - Al Sol Globos (Estado de Mexico) - Takeoff Zone
- **HSL** - Hospital Star Medica Leon (Guanajuato) - Heliport
- **HSI** - Servicios Aereos Ilsa (Baja California Sur) - Heliport
- **VBS** - Valle de Banderas (Revocación) (Nayarit) - Aerodrome (status updated)
- **BNZ** - Bonanza (Fallecimiento de Titular) (Baja California) - Aerodrome (status updated)
- Hotel Solaris (Morelos) - Heliport
- Helicopters Air Space (Jalisco) - Heliport
- **HXU** - Campeche (Campeche) - Heliplatform
- **HXV** - Chihuahua (Campeche) - Heliplatform
- **HXW** - Tabasco (Campeche) - Heliplatform
- **HXX** - Zacatecas (Campeche) - Heliplatform

**Facilities Removed (7 total)**
- Entries were cleaned up, updated with proper designators, or marked with updated statuses

**KMZ Filenames**
- Updated from "09-25" to "11-25" to reflect November 2025 data
- `FEMPPA Apts 11-25.kmz` (was `FEMPPA Apts 09-25.kmz`)
- `FEMPPA Heli 11-25.kmz` (was `FEMPPA Heli 09-25.kmz`)

**Distribution Package**
- Updated from `FEMPPA-Mexican-Airports-v2.0.zip` to `FEMPPA-Mexican-Airports-v2.1.zip`

### Technical Changes

**Database Schema Updates**
- AFAC removed three columns from the November 2025 format:
  - **AERONAVE CRITICA** (Critical Aircraft) - Column removed entirely
  - **MES** (Month) - Column removed entirely
  - **AÑO** (Year) - Column removed entirely
- Date and status columns shifted left due to removed columns
- Script updated to handle new column structure (columns 24-29 instead of 25-32)

**Coordinate System Standardization**
- 605 entries updated from "WGS 84" to "WGS-84" format for consistency
- Improves data uniformity across the database

**Data Quality Improvements**
- Fixed column misalignment issues that affected date fields in previous version
- Issue dates, expiration dates, and permit durations now correctly parsed
- Active status and coordination airport fields properly aligned

### Data Source

**AFAC (Agencia Federal de Aviación Civil) Aerodrome Database**
- File: `aerodromos-helipuertos-pub-301125-02122025.xlsx`
- Published: November 30, 2025
- Entries: 2,170 Mexican facilities
- Columns: 30 (reduced from 33 due to removed fields)
- Source: https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos

### Installation

**Upgrading from a previous version:** Delete the old pack in ForeFlight (More > Content > swipe left to delete) before importing.

1. Download `FEMPPA-Mexican-Airports-v2.1.zip`
2. Transfer to your device and open ForeFlight > More > Content > Import
3. Select the ZIP file to import
4. Toggle layers: Map > Layers > FEMPPA Mexican Airports / FEMPPA Mexican Heliports

**Optional:** Disable auto-zoom in More > Settings > Layer Selector > Auto-Zoom to Custom Content

### Historical Database Archive

Starting with v2.1, all AFAC source databases are preserved in the `afac-sources/` directory:
- `base-aerodromo-helipuertos-pub-28022025.xlsx` (February 2025)
- `aerodromos-helipuertos-pub-300925-01102025.xlsx` (September 2025)
- `aerodromos-helipuertos-pub-301125-02122025.xlsx` (November 2025)

---

## [2.0] - 2025-11-19

### Breaking Changes

**Dual-Layer Architecture**
- Custom pack now provides two separate layers instead of one:
  - **FEMPPA Mexican Airports** (`FEMPPA Apts 09-25.kmz`) - Aerodromes, seaplane bases, and mixed-use facilities
  - **FEMPPA Mexican Heliports** (`FEMPPA Heli 09-25.kmz`) - Heliports, heliplatforms, takeoff zones, and boat/platform heliports
- Users can now toggle airports and heliports independently in ForeFlight's layer selector
- "Aerodrome Heliport" facilities appear in both layers with appropriate icons (aerodrome icon in Airports layer, heliport icon in Heliports layer)

**Layer Naming**
- Previous: "Mexican Airports"
- New: "FEMPPA Mexican Airports" and "FEMPPA Mexican Heliports"
- Organization: FEMPPA (Federación Mexicana de Pilotos y Propietarios de Aeronaves)

### Added

**Geographic Data Validation**
- Implemented coordinate validation to filter out data errors
- Valid range: Latitude 14°-33°N, Longitude 86°-119°W (Mexico's geographic boundaries)
- Eliminates erroneous entries (e.g., facilities with incorrect coordinates like XAGA's 11° longitude)
- Ensures all displayed facilities are within Mexican territory

**3D Elevation Data for Flight Planning**
- KML coordinates now include actual elevation values in meters (previously hardcoded to 0)
- Enables ForeFlight to calculate proper climb/descent paths when planning routes to/from these waypoints
- Provides accurate terrain awareness and Profile View display
- Supports fuel calculation based on altitude changes

**Dual-Unit Runway Measurements**
- Runway dimensions now display in both imperial and metric units
- Format example: "3,937 ft (1,200 m) × 98 ft (30 m)"
- Improves usability for pilots familiar with either measurement system
- Maintains consistency with elevation display format (feet first, meters in parentheses)

**ForeFlight User Documentation**
- Added guidance for managing ForeFlight's auto-zoom behavior
- Instructions for disabling "Auto-Zoom to Custom Content" setting
- Prevents unwanted zoom-out when toggling 2,000+ facility layers
- Path documented: More > Settings > Layer Selector > Auto-Zoom to Custom Content

### Changed

**Icon Assignment**
- Heliplatforms now use heliport icons (previously used takeoff_zone icons)
- Aerodrome Heliport facilities use layer-appropriate icons (aerodrome in Airports layer, heliport in Heliports layer)

**Layer Names Optimized**
- Shortened from "Mexican Airports (02-2025)" to "FEMPPA Apts 09-25"
- Fits better in ForeFlight's Map Layers menu without truncation
- Date format simplified (09-25 instead of 02-2025)

**Organization Branding**
- Updated from "VogelitoAir" to "FEMPPA"
- Reflects FEMPPA's role as Mexico's aviation pilot and aircraft owner federation

**Distribution Package**
- Custom pack filename changed from `CustomMexicanAirportsCustomPack.zip` to `FEMPPA-Mexican-Airports-v2.0.zip`
- New naming convention: clearer branding, includes version number, removes redundant "Custom" terminology
- Future releases will follow pattern: `FEMPPA-Mexican-Airports-v[version].zip`

### Fixed

**Coordinate Accuracy**
- Removed facilities with invalid coordinates that appeared outside Mexico
- Proper handling of zero-coordinate entries (0,0)
- Eliminated Atlantic Ocean pan issue caused by erroneous longitude values

**Display Consistency**
- Runway dimensions formatting improved for readability
- Elevation displayed consistently across all fields
- Layer names no longer truncated in ForeFlight UI

### Technical Improvements

**Code Architecture**
- Refactored KML generation into reusable `generate_kml_for_layer()` method
- Added `belongs_to_layer?()` filter function for type-based layer assignment
- Translation maps now passed as hash parameter for better maintainability
- Supports future expansion to additional layer types

**Data Quality**
- Comprehensive translation maps for Spanish-to-English term mappings (200+ terms)
- Enhanced data validation pipeline:
  1. Zero-coordinate filtering
  2. Geographic boundary validation
  3. Layer-specific filtering
- Consistent coordinate system handling (WGS 84/NAD 27 documented)

**Performance**
- Processes 2,162+ aerodrome entries from AFAC database
- Generates two optimized KMZ files with embedded style icons
- Maintains fast ForeFlight load times despite dual-layer architecture

### Migration Notes (v1.0 → v2.0)

**For Users:**
- Previous single layer "Mexican Airports" is replaced by two layers
- Both layers are included in the custom pack ZIP file
- Import once, then toggle each layer independently as needed
- Consider which layer(s) suit your flight operations (most pilots will only need Airports layer)
- No data loss - all facilities from v1.0 are included across the two layers

**For Developers:**
- Script now generates both layers in a single execution
- Layer filtering occurs during placemark iteration
- Dual KMZ generation adds ~10-15 seconds to build time
- New helper function structure improves code reusability

### Data Source

**AFAC (Agencia Federal de Aviación Civil) Aerodrome Database**
- File: `aerodromos-helipuertos-pub-300925-01102025.xlsx`
- Published: October 2025
- Entries: 2,162+ Mexican facilities
- Columns: 33 (vs. 23 in previous format)
- Source: https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos

**New Data Fields (added in v1.0-2.0 cycle):**
- Runway orientation, length, width, surface type
- Critical aircraft specifications
- Classification (Land-based, Elevated, Surface, etc.)
- Owner/permit holder names
- Coordinate system documentation
- Permit dates and status

### Installation

1. Download `FEMPPA-Mexican-Airports-v2.0.zip`
2. Transfer to your device with ForeFlight
3. Open ForeFlight > More > Content > Import
4. Select the ZIP file to import
5. Toggle layers: Map > Layers > FEMPPA Mexican Airports / FEMPPA Mexican Heliports

**Optional:** Disable auto-zoom in More > Settings > Layer Selector > Auto-Zoom to Custom Content

### Known Limitations

**ForeFlight Custom Content Constraints:**
- Zoom-based progressive loading (like ForeFlight's built-in Aeronautical layer) is not available for custom KML content
- All placemarks in a layer are always visible regardless of zoom level
- Custom waypoints remain "user waypoints" and don't integrate into ForeFlight's official airport database search
- KML `<Region>` and `<Lod>` elements are not supported by ForeFlight

**Workarounds:**
- Use the dual-layer system to toggle visibility as needed
- Airports and Heliports can be viewed independently to reduce clutter
- Disable auto-zoom setting to maintain current view when toggling

### Contributors

Published by FEMPPA (Federación Mexicana de Pilotos y Propietarios de Aeronaves)

Data source: AFAC (Agencia Federal de Aviación Civil)

---

## [1.0] - 2025-02-03

### Initial Release

**Features:**
- Single custom layer with all Mexican aerodromes
- Basic placemark information (name, type, location)
- Excel-to-KML conversion from AFAC database
- ForeFlight custom pack packaging

---

[2.2]: https://github.com/vogelito/foreflight-mexican-airports/compare/v2.1...v2.2
[2.1]: https://github.com/vogelito/foreflight-mexican-airports/compare/v2.0...v2.1
[2.0]: https://github.com/vogelito/foreflight-mexican-airports/compare/v1.0...v2.0
[1.0]: https://github.com/vogelito/foreflight-mexican-airports/releases/tag/v1.0
