# Changelog

All notable changes to the ForeFlight Mexican Airports Custom Pack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

1. Download `CustomMexicanAirportsCustomPack.zip`
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

[2.0]: https://github.com/vogelito/foreflight-mexican-airports/compare/v1.0...v2.0
[1.0]: https://github.com/vogelito/foreflight-mexican-airports/releases/tag/v1.0
