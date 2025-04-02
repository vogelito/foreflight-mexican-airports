# ForeFlight Mexican Airports Custom Pack

This repository contains a Ruby script to convert the [AFAC Mexican Aerodrome Excel file](https://www.gob.mx/afac/acciones-y-programas/base-de-datos-de-aerodromos-y-helipuertos) into a KML file that can then be packaged as a custom pack for ForeFlight to display airport data on its maps.

## Features

- Reads an Excel file with airport data.
- Filters for valid aerodromes.
- Generates a KML file with placemarks for each airport.
- Easy to update and extend with new data.

## Getting Started

### Prerequisites

- [Ruby](https://www.ruby-lang.org/en/downloads/)
- Gems: `roo`, `builder`
  
Install the required gems:

```bash
gem install roo builder
```

### Usage
1. Place your Excel file (`base-aerodromo-helipuertos-pub-28022025.xlsx`) in the `data/` folder.
1. Run the Ruby script:
```bash
ruby script/create_custom_pack.rb
```
1. The generated KML file will be saved (e.g., `custom_mexican_airports.kml`).
1. Package your custom pack by placing the KML file into the appropriate folder structure and zipping it up for ForeFlight.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.
