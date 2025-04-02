#!/usr/bin/env ruby
require 'roo'
require 'builder'

# Input and output file paths
excel_file = 'data/base-aerodromo-helipuertos-pub-28022025.xlsx'
output_kml_file = 'data/custom_mexican_airports.kml'

# Open the Excel file (assumes .xlsx format)
xlsx = Roo::Excelx.new(excel_file)
sheet = xlsx.sheet(0)

# Create the KML file using Builder
File.open(output_kml_file, "w") do |file|
  xml = Builder::XmlMarkup.new(target: file, indent: 2)
  xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
  xml.kml(xmlns: "http://www.opengis.net/kml/2.2") do
    xml.Document do
      xml.name("Custom Mexican Airports")
      
      # Iterate over rows, skipping the first two rows which contain headers.
      # Expected headers and their translations:
      # [0] "NO. DE EXPEDIENTE" → File Number
      # [1] "TIPO AERÓDROMO" → Aerodrome Type
      # [2] "DESIGNADOR" → Identifier
      # [3] "NOMBRE" → Name
      # [4] "ESTADO" → State
      # [5] "MUNICIPIO" → Municipality
      # [6] "TIPO DE OPERACIÓN" → Type of Operation
      # [7] "TIPO DE SERVICIO" → Type of Service
      # [8] "NOMBRE" → Name (alternate)
      # [9] "ELEV (M)" → Elevation (M)
      # [10] "LATITUD\n°" → Latitude (Degrees)
      # [11] "LATITUD\n'" → Latitude (Minutes)
      # [12] "LATITUD\n''" → Latitude (Seconds)
      # [13] "LONGITUD\n°" → Longitude (Degrees)
      # [14] "LONGITUD\n'" → Longitude (Minutes)
      # [15] "LONGITUD\n''" → Longitude (Seconds)
      # [16] "FECHA DE EXPEDICIÓN" → Issue Date
      # [17] "DURACIÓN DEL PERMISO/AUTORIZACIÓN" → Permit/Authorization Duration
      # [18] "FECHA DE VENCIMIENTO" → Expiration Date
      # [19] "MES" → Month
      # [20] "AÑO" → Year
      # [21] "¿VIGENTE?" → Active?
      # [22] "SITUACIÓN" → Status

      (1..sheet.last_row).each do |i|
        next if i < 3  # Skip the first two rows

        row = sheet.row(i)
        
        file_number       = row[0]
        aerodrome_type    = row[1]
        identifier        = row[2]
        name              = row[3]
        state             = row[4]
        municipality      = row[5]
        type_of_operation = row[6]
        type_of_service   = row[7]
        name_alt          = row[8]
        elevation         = row[9]
        lat_deg           = row[10].to_f
        lat_min           = row[11].to_f
        lat_sec           = row[12].to_f
        lon_deg           = row[13].to_f
        lon_min           = row[14].to_f
        lon_sec           = row[15].to_f
        issue_date        = row[16]
        permit_duration   = row[17]
        expiration_date   = row[18]
        month             = row[19]
        year              = row[20]
        active            = row[21]
        status            = row[22]
        
        # Convert the DMS coordinates to decimal degrees
        decimal_latitude  = lat_deg + (lat_min / 60.0) + (lat_sec / 3600.0)
        decimal_longitude = lon_deg + (lon_min / 60.0) + (lon_sec / 3600.0)
        
        # Build a description string using the translated field names
        description = <<~DESC
          File Number: #{file_number}
          Aerodrome Type: #{aerodrome_type}
          Identifier: #{identifier}
          Name: #{name}
          State: #{state}
          Municipality: #{municipality}
          Type of Operation: #{type_of_operation}
          Type of Service: #{type_of_service}
          Alternate Name: #{name_alt}
          Elevation (M): #{elevation}
          Latitude: #{lat_deg}° #{lat_min}' #{lat_sec}"
          Longitude: #{lon_deg}° #{lon_min}' #{lon_sec}"
          Issue Date: #{issue_date}
          Permit/Authorization Duration: #{permit_duration}
          Expiration Date: #{expiration_date}
          Month: #{month}
          Year: #{year}
          Active?: #{active}
          Status: #{status}
        DESC

        # Create a Placemark for each row
        xml.Placemark do
          xml.name(name)
          # Wrap the description in CDATA to preserve special characters
          xml.description("<![CDATA[#{description}]]>")
          xml.Point do
            # KML coordinates are in "longitude,latitude,altitude" format; altitude is set to 0
            xml.coordinates("#{decimal_longitude},#{decimal_latitude},0")
          end
        end
      end
    end
  end
end

puts "KML file created successfully: #{output_kml_file}"
