# ForeFlight Mexican Airports Custom Pack

This repository contains a Ruby script to convert the [AFAC Mexican Aerodrome Excel file](https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos) into a KML file that can then be packaged as a custom pack for ForeFlight to display airport data on its maps.

## Features

- Reads an Excel file with airport data.
- Filters for valid aerodromes.
- Generates a KML file with placemarks for each airport, including:
  - Basic information (name, type, location, elevation)
  - Runway data (orientation, dimensions, surface type)
  - Critical aircraft specifications
  - Operating status and permit information
- Easy to update and extend with new data.

## Getting Started

### Prerequisites

- [Ruby](https://www.ruby-lang.org/en/downloads/)
- Gems: `roo`, `builder`
  
Install the required gems:

```bash
gem install roo builder rubyzip
```

### Usage
1. Download the latest Excel file from [AFAC's website](https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos) and place it in the `data/` folder (e.g., `aerodromos-helipuertos-pub-300925-01102025.xlsx`).
1. Update the filename in `script/create_custom_pack.rb` if needed.
1. Run the Ruby script:
   ```bash
   ruby script/create_custom_pack.rb
   ```
1. The script will generate:
   - `data/custom_mexican_airports.kml` - KML file with airport data
   - `data/custom_mexican_airports.kmz` - Compressed KMZ with icons
   - `CustomMexicanAirportsCustomPack.zip` - Final ForeFlight custom pack

### SVG to PNG
```bash
rsvg-convert -w 80 -h 80 -a -o assets/airfield_green.svg.png assets/airfield_green.svg
```

## ForeFlight Usage Tips

### Preventing Auto-Zoom When Toggling Layers

By default, ForeFlight zooms out to show all Mexican airports when you toggle the FEMPPA layers on. To prevent this behavior and keep your current map view:

1. Open ForeFlight
2. Go to **More** > **Settings** > **Layer Selector**
3. Toggle OFF **"Auto-Zoom to Custom Content"**

This allows you to toggle the FEMPPA Apts and FEMPPA Heli layers without changing your current map view or zoom level.

**Note:** This is a ForeFlight setting that affects all custom content layers, not just FEMPPA layers.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.
