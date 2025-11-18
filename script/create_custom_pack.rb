#!/usr/bin/env ruby
require 'roo'
require 'builder'
require 'zip'
require 'fileutils'
require 'json'

# --- Configuration and Paths ---
excel_file       = 'data/aerodromos-helipuertos-pub-300925-01102025.xlsx'
kml_file         = 'data/custom_mexican_airports.kml'
kmz_file         = 'data/custom_mexican_airports.kmz'
build_dir        = 'build_pack'
navdata_dir      = File.join(build_dir, 'navdata')
custom_pack_zip  = 'CustomMexicanAirportsCustomPack.zip'

# --- Translation Maps ---
aerodrome_type_map = {
  "AERÓDROMO" => "Aerodrome",
  "AERÓDROMO ACUÁTICO" => "Seaplane Base",
  "AERÓDROMO HELIPUERTO" => "Aerodrome Heliport",
  "BARCO-HELIPUERTO" => "Heliport (Boat)",
  "HELIPUERTO" => "Heliport",
  "HELIPLATAFORMA" => "Heliplatform",
  "PLATAFORMA-HELIPUERTO" => "Heliport Platform",
  "ZONA DE DESPEGUE" => "Takeoff Zone"
}

operation_type_map = {
  "" => "",
  "DIRUNO" => "Daytime",      # corrected typo to Daytime
  "DIURNO" => "Daytime",
  "DIURNO Y NOCTURNO" => "Day and Night",
  "NOCTURNO" => "Night"
}

service_type_map = {
  "" => "",
  "SERVICIO PARTICULAR" => "Private Service",
  "SERVICIO PARTICULAR / EN TRAMITE SERV. A TERCERROS" => "Private / Pending Third-Party Service",
  "SERVICIO PARTICULAR Y A TERCEROS" => "Private and Third-Party Service"
}

active_map = {
  "NO" => "No",
  "SI" => "Yes"
}

status_map = {
  "CERRADO POR NOTAM" => "Closed by NOTAM",
  "DESISTIMIENTO DEL  TRAMITE" => "Procedure Withdrawal",
  "DESISTIMIENTO DEL TRAMITE" => "Procedure Withdrawal",
  "EN TRAMITE" => "In Process",
  "EN TRAMITE DE CANCELACION" => "Cancellation in Process",
  "INOPERATIVO" => "Inoperative",
  "INOPERATIVO (RENUNCIA DEL TITULAR)" => "Inoperative (Owner Renunciation)",
  "INOPERATIVO POR SISMO" => "Inoperative Due to Earthquake",
  "MILITAR" => "Military",
  "SIN PERMISO POR FALLECIMIEMTO DE TITULAR" => "No Permit (Owner's Death)",
  "SIN PERMISO POR FALLECIMIENTO DE TITULAR" => "No Permit (Owner's Death)",
  "VIGEMTE" => "Active",
  "VIGENTE" => "Active"
}

# Additional translation maps for dates and duration.
issue_date_map = {
  "PROYECTO" => "Project",
  "SIN AUTORIZACION" => "Not Authorized",
  "SIN AUTORIZACIÓN" => "Not Authorized",
  "SUSPENSIÓN DE ACTIVIDADES" => "Suspension of Activities"
}

expiration_date_map = {
  "PROYECTO" => "Project",
  "SIN AUTORIZACION" => "Not Authorized",
  "SIN AUTORIZACIÓN" => "Not Authorized",
  "SUSPENSIÓN DE ACTIVIDADES" => "Suspension of Activities"
}

duration_units_map = {
  "DIAS" => "Days",
  "DÍAS" => "Days",
  "AÑO" => "Year",
  "AÑOS" => "Years",
  "MESES" => "Months",
  "SIN AUTORIZACIÓN" => "Not Authorized",
  "UNICA OCACIÓN" => "One Time",
  "SUSPENSIÓN DE ACTIVIDADES" => "Suspension of Activities",
  "PROYECTO" => "Project"
}

classification_map = {
  "TERRESTRE" => "Land-based",
  "ELEVADO" => "Elevated",
  "SUPERFICIE" => "Surface",
  "HELIPUERTO MIXTO" => "Mixed Heliport",
  "ACUATICO" => "Aquatic",
  "METALICA" => "Metallic"
}

surface_type_map = {
  "TERRACERÍA" => "Dirt",
  "TERRACERIA" => "Dirt",
  "TERRAERIA" => "Dirt",
  "ASFALTO" => "Asphalt",
  "CONCRETO" => "Concrete",
  "cONCRETO" => "Concrete",
  "CONCRETO HIDRAULICO" => "Hydraulic Concrete",
  "CONCRETO HIDRÁULICO" => "Hydraulic Concrete",
  "CONCRETO HIDRAHULICO Y TERRACERIA" => "Hydraulic Concrete and Dirt",
  "CONCRETO HIDRÁULICO Y TERRACERIA" => "Hydraulic Concrete and Dirt",
  "METALICA" => "Metal",
  "METÁLICA" => "Metal",
  "ALUMINIO" => "Aluminum",
  "PASTO" => "Grass",
  "AGUA" => "Water",
  "ACUÁTICA" => "Aquatic",
  "MIXTA" => "Mixed",
  "TERRENO NATURAL" => "Natural Terrain",
  "SUELO COMPACTADO" => "Compacted Soil",
  "PIEDRA COMPACTADA" => "Compacted Stone",
  "TEPETATE COMPACTADO" => "Compacted Tepetate",
  "PLACA METALICA" => "Metal Plate",
  "TERRACERIA COMPACTADA" => "Compacted Dirt",
  "TERRACERÍA COMPACTADA" => "Compacted Dirt",
  "PAVIMENTO ASFALTICO" => "Asphalt Pavement",
  "TERRENO NATURAL CON PASTO" => "Natural Terrain with Grass",
  "TERRENO NATURAL DE ARCILLA COMPACTADA" => "Natural Compacted Clay Terrain"
}

aircraft_generic_map = {
  "NO DISPONIBLE" => "Not Available",
  "SE DESCONOCE" => "Unknown",
  "PENDIENTE" => "Pending",
  "ULTRALIGEROS" => "Ultralight",
  "MONOMOTORES" => "Single-engine",
  "BIMOTORES" => "Twin-engine"
}

def translate_duration(duration, duration_units_map)
  duration = duration.strip
  return duration if duration.empty?
  if duration =~ /^(\d+)\s*([[:alpha:]]+)/
    number = $1
    unit = $2
    translated_unit = duration_units_map[unit.upcase] || unit
    "#{number} #{translated_unit}"
  else
    duration_units_map[duration.upcase] || duration
  end
end

# Conversion factor: 1 meter = 3.28084 feet
METER_TO_FEET = 3.28084

# --- Step 1: Generate the KML File ---
puts "Generating KML file from Excel data..."
xlsx = Roo::Excelx.new(excel_file)
sheet = xlsx.sheet(0)

File.open(kml_file, "w") do |file|
  xml = Builder::XmlMarkup.new(target: file, indent: 2)
  xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
  xml.kml(xmlns: "http://www.opengis.net/kml/2.2") do
    xml.Document do
      xml.name("Custom Mexican Airports")

      # --- Add Styles for each combination of Aerodrome Type and Status ---
      # Define styles for each base type and status version.
      ["aerodrome", "heliport", "seaplane_base", "takeoff_zone"].each do |base|
        ["active", "in_permit", "inactive"].each do |suffix|
          style_id = "#{base}_#{suffix}"
          icon_href = "files/#{base}_#{suffix}.png"
          xml.Style(:id => style_id) do
            xml.IconStyle do
              xml.colorMode("normal")
              xml.scale("1")
              xml.heading("0")
              xml.Icon do
                xml.href(icon_href)
              end
            end
          end
        end
      end

      # Iterate over rows, skipping the first two header rows.
      # Expected column indices (0-based) and translations:
      #  0: NO. DE EXPEDIENTE         → File Number
      #  1: TIPO AERÓDROMO            → Aerodrome Type
      #  2: DESIGNADOR                → Identifier
      #  3: NOMBRE                    → Name
      #  4: ESTADO                    → State
      #  5: MUNICIPIO                 → Municipality
      #  6: TIPO DE OPERACIÓN         → Type of Operation
      #  7: TIPO DE SERVICIO          → Type of Service
      #  8: CLASIFICACION             → Classification
      #  9: CLAVE DE REFERENCIA       → Reference Key
      # 10: NOMBRE (propietario)      → Owner
      # 11: ELEV (M)                  → Elevation (M) [to be converted to feet]
      # 12: SISTEMA                   → Coordinate System
      # 13: LATITUD °                → Latitude (Degrees)
      # 14: LATITUD '                → Latitude (Minutes)
      # 15: LATITUD ''               → Latitude (Seconds)
      # 16: LONGITUD °               → Longitude (Degrees)
      # 17: LONGITUD '               → Longitude (Minutes)
      # 18: LONGITUD ''              → Longitude (Seconds)
      # 19: ORIENTACION 1A            → Runway Orientation 1
      # 20: ORIENTACION 2A            → Runway Orientation 2
      # 21: LONGITUD DE PISTA A       → Runway Length
      # 22: ANCHO DE PISTA A          → Runway Width
      # 23: TIPO DE SUPERFICIE A      → Surface Type
      # 24: AERONAVE CRITICA          → Critical Aircraft
      # 25: FECHA DE EXPEDICIÓN       → Issue Date
      # 26: DURACIÓN DEL PERMISO/AUTORIZACIÓN → Permit/Authorization Duration
      # 27: FECHA DE VENCIMIENTO      → Expiration Date
      # 28: MES                       → Month
      # 29: AÑO                       → Year
      # 30: ¿VIGENTE?                → Active?
      # 31: SITUACIÓN                 → Status
      # 32: AEROPUERTO DE CORDINACIÓN → Coordination Airport

      (1..sheet.last_row).each do |i|
        next if i < 3  # Skip header rows

        row = sheet.row(i)
        
        file_number       = row[0].to_s.strip
        aerodrome_type    = row[1].to_s.strip
        identifier        = "X#{row[2].to_s.strip}"
        name              = row[3].to_s.strip
        state             = row[4].to_s.strip
        municipality      = row[5].to_s.strip
        type_of_operation = row[6].to_s.strip
        type_of_service   = row[7].to_s.strip
        classification    = row[8].to_s.strip
        reference_key     = row[9].to_s.strip
        owner             = row[10].to_s.strip
        elevation_m       = row[11].to_f
        coord_system      = row[12].to_s.strip
        lat_deg           = row[13].to_f
        lat_min           = row[14].to_f
        lat_sec           = row[15].to_f
        lon_deg           = row[16].to_f
        lon_min           = row[17].to_f
        lon_sec           = row[18].to_f
        runway_orient_1   = row[19].to_s.strip
        runway_orient_2   = row[20].to_s.strip
        runway_length     = row[21].to_s.strip
        runway_width      = row[22].to_s.strip
        surface_type      = row[23].to_s.strip
        critical_aircraft = row[24].to_s.strip
        issue_date        = row[25].to_s.strip
        permit_duration   = row[26].to_s.strip
        expiration_date   = row[27].to_s.strip
        month             = row[28].to_s.strip
        year              = row[29].to_s.strip
        active            = row[30].to_s.strip
        status            = row[31].to_s.strip
        coordination_apt  = row[32].to_s.strip
        
        # Apply translations using mapping hashes.
        translated_aerodrome_type = aerodrome_type_map[aerodrome_type] || aerodrome_type
        translated_operation_type  = operation_type_map[type_of_operation] || type_of_operation
        translated_service_type    = service_type_map[type_of_service] || type_of_service
        translated_active          = active_map[active.upcase] || active
        translated_status          = status_map[status.upcase] || status

        # Translate date and duration fields.
        translated_issue_date = issue_date_map[issue_date.upcase] || issue_date
        translated_expiration_date = expiration_date_map[expiration_date.upcase] || expiration_date
        translated_permit_duration = translate_duration(permit_duration, duration_units_map)

        # Translate new fields.
        translated_classification = classification_map[classification.upcase] || classification
        translated_surface_type = surface_type_map[surface_type.upcase] || surface_type
        translated_aircraft = aircraft_generic_map[critical_aircraft.upcase] || critical_aircraft

        # Convert elevation from meters to feet.
        elevation_ft = (elevation_m * METER_TO_FEET).round(2)
        
        # Convert DMS (Degrees, Minutes, Seconds) to decimal degrees.
        decimal_latitude  = lat_deg + (lat_min / 60.0) + (lat_sec / 3600.0)
        decimal_longitude = -(lon_deg + (lon_min / 60.0) + (lon_sec / 3600.0))
        next if decimal_latitude == 0 && decimal_longitude == 0

        # Determine the base icon name from the aerodrome type.
        case translated_aerodrome_type
        when "Aerodrome"
          base = "aerodrome"
        when "Heliport", "Heliport (Boat)", "Heliport Platform"
          base = "heliport"
        when "Seaplane Base"
          base = "seaplane_base"
        when "Takeoff Zone"
          base = "takeoff_zone"
        else
          base = "aerodrome"
        end

        # Determine which icon status to use: active, in_permit, or inactive.
        if translated_status == "Active"
          icon_suffix = "active"
        elsif translated_status == "In Process"
          icon_suffix = "in_permit"
        else
          icon_suffix = "inactive"
        end

        style_id = "#{base}_#{icon_suffix}"
        
        # Build a nicely formatted HTML description
        description = <<~HTML
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <style>
              /* Basic styling reminiscent of ForeFlight */
              body {
                font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
                margin: 0;
                padding: 0;
                color: #333;
              }
              .airport-info {
                padding-top: 1px;
              }
              .airport-title {
                background-color: #1e374f;
                color: #fff;
                font-size: 40px;
                padding: 8px;
                margin-bottom: 1px;
              }
              table {
                width: 100%;
                border-collapse: collapse;
                padding-top: 1px;
                padding-bottom: 1px;
              }
              .label {
                width: 40%;
                font-weight: 600;
                padding: 4px;
                background-color: #f2f2f2;
                font-size: 40px;
              }
              .value {
                width: 60%;
                padding: 4px;
                font-size: 40px;
              }
              .spacer {
                height: 1px;
              }
            </style>
          </head>
          <body>
            <div class="airport-info">
              <div class="airport-title">#{name} (#{identifier})</div>
              <table>
                <tr>
                  <td class="label">File Number</td>
                  <td class="value">#{file_number}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Aerodrome Type</td>
                  <td class="value">#{translated_aerodrome_type}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Identifier</td>
                  <td class="value">#{identifier}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Name</td>
                  <td class="value">#{name}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">State</td>
                  <td class="value">#{state}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Municipality</td>
                  <td class="value">#{municipality}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Type of Operation</td>
                  <td class="value">#{translated_operation_type}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Type of Service</td>
                  <td class="value">#{translated_service_type}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Classification</td>
                  <td class="value">#{translated_classification}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Reference Key</td>
                  <td class="value">#{reference_key}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Owner</td>
                  <td class="value">#{owner}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Elevation</td>
                  <td class="value">#{elevation_ft} ft (#{elevation_m} m)</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Coordinate System</td>
                  <td class="value">#{coord_system}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Latitude</td>
                  <td class="value">#{lat_deg}° #{lat_min}' #{lat_sec}"</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Longitude</td>
                  <td class="value">#{lon_deg}° #{lon_min}' #{lon_sec}"</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Runway Orientation</td>
                  <td class="value">#{runway_orient_1}#{runway_orient_2.empty? ? '' : ' / ' + runway_orient_2}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Runway Dimensions</td>
                  <td class="value">#{runway_length.empty? ? 'N/A' : runway_length + ' m'}#{runway_width.empty? ? '' : ' × ' + runway_width + ' m'}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Runway Surface</td>
                  <td class="value">#{translated_surface_type}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Critical Aircraft</td>
                  <td class="value">#{translated_aircraft}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Issue Date</td>
                  <td class="value">#{translated_issue_date}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Permit/Authorization Duration</td>
                  <td class="value">#{translated_permit_duration}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Expiration Date</td>
                  <td class="value">#{translated_expiration_date}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Month</td>
                  <td class="value">#{month}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Year</td>
                  <td class="value">#{year}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Active?</td>
                  <td class="value">#{translated_active}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Status</td>
                  <td class="value">#{translated_status}</td>
                </tr>
                <tr>
                  <td colspan="2" class="spacer"></td>
                </tr>
                <tr>
                  <td class="label">Coordination Airport</td>
                  <td class="value">#{coordination_apt}</td>
                </tr>
              </table>
            </div>
          </body>
        HTML

        # Build a description string using the translated field names and values.
        description2 = <<~DESC
          File Number: #{file_number}
          Aerodrome Type: #{translated_aerodrome_type}
          Identifier: #{identifier}
          Name: #{name}
          State: #{state}
          Municipality: #{municipality}
          Type of Operation: #{translated_operation_type}
          Type of Service: #{translated_service_type}
          Classification: #{translated_classification}
          Reference Key: #{reference_key}
          Owner: #{owner}
          Elevation: #{elevation_ft} ft (#{elevation_m} m)
          Coordinate System: #{coord_system}
          Latitude: #{lat_deg}° #{lat_min}' #{lat_sec}"
          Longitude: #{lon_deg}° #{lon_min}' #{lon_sec}"
          Runway Orientation: #{runway_orient_1}#{runway_orient_2.empty? ? '' : ' / ' + runway_orient_2}
          Runway Dimensions: #{runway_length.empty? ? 'N/A' : runway_length + ' m'}#{runway_width.empty? ? '' : ' × ' + runway_width + ' m'}
          Runway Surface: #{translated_surface_type}
          Critical Aircraft: #{translated_aircraft}
          Issue Date: #{translated_issue_date}
          Permit/Authorization Duration: #{translated_permit_duration}
          Expiration Date: #{translated_expiration_date}
          Month: #{month}
          Year: #{year}
          Active?: #{translated_active}
          Status: #{translated_status}
          Coordination Airport: #{coordination_apt}
        DESC

        puts description2

        # Create a Placemark for this row.
        xml.Placemark do
          # Some rows don't include an identifier, so use the name for those
          id_value = identifier == "X" ? name : identifier
          xml.name(id_value)
          xml.styleUrl("##{style_id}")
          # Use CDATA to preserve formatting and special characters.
          xml.description("<![CDATA[#{description}]]>")
          xml.Point do
            # KML requires coordinates in "longitude,latitude,altitude" format.
            xml.coordinates("#{decimal_longitude},#{decimal_latitude},0")
          end
        end
      end
    end
  end
end
puts "KML file created successfully: #{kml_file}"

# --- Step 2: Package the KML as a KMZ File ---
puts "Packaging KML into KMZ file..."
# Remove existing KMZ file if it exists.
FileUtils.rm_f(kmz_file)
# A KMZ is a ZIP file containing the KML file named "doc.kml"
Zip::File.open(kmz_file, create: true) do |zipfile|
  zipfile.add("doc.kml", kml_file)
  # Add a "files" folder with all the icon PNGs inside the KMZ.
  zipfile.mkdir("files") unless zipfile.find_entry("files/")
  ["aerodrome", "heliport", "seaplane_base", "takeoff_zone"].each do |base|
    ["active", "in_permit", "inactive"].each do |suffix|
      icon_path = "assets/#{base}_#{suffix}.png"
      zipfile.add("files/#{base}_#{suffix}.png", icon_path)
    end
  end
end
puts "KMZ file created successfully: #{kmz_file}"

# --- Step 3: Create the Custom Pack Folder Structure and manifest.json ---
puts "Creating custom pack folder structure..."
# Remove any existing build directory.
FileUtils.rm_rf(build_dir) if Dir.exist?(build_dir)
FileUtils.mkdir_p(navdata_dir)

# Create the manifest.json content.
manifest_content = {
  "name" => "Mexican Airports",
  "version" => 1.0,
  "expirationDate" => "20260204T210121",
  "effectiveDate" => "20250203T210121",
  "noShare" => "true",
  "organizationName" => "FEMPPA"
}
File.write(File.join(build_dir, "manifest.json"), JSON.pretty_generate(manifest_content))

# Copy the KMZ file into the navdata directory.
kmz_filename = "FEMPPA Apts 09-25.kmz"
FileUtils.cp(kmz_file, File.join(navdata_dir, kmz_filename))
puts "Custom pack structure created successfully in '#{build_dir}'"

# --- Step 4: Package the Custom Pack as a ZIP File ---
puts "Packaging the custom pack into a ZIP file..."
# Remove existing custom pack ZIP if it exists.
FileUtils.rm_f(custom_pack_zip)
def zip_directory(input_dir, output_file)
  entries = Dir.entries(input_dir) - %w[. ..]
  Zip::File.open(output_file, create: true) do |zipfile|
    write_entries(entries, input_dir, '', zipfile)
  end
end

def write_entries(entries, path, parent_path, zipfile)
  entries.each do |entry|
    full_path = File.join(path, entry)
    zip_entry = parent_path.empty? ? entry : File.join(parent_path, entry)
    if File.directory?(full_path)
      zipfile.mkdir(zip_entry)
      sub_entries = Dir.entries(full_path) - %w[. ..]
      write_entries(sub_entries, full_path, zip_entry, zipfile)
    else
      zipfile.add(zip_entry, full_path)
    end
  end
end

zip_directory(build_dir, custom_pack_zip)
puts "Custom pack ZIP file created successfully: #{custom_pack_zip}"
