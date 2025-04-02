#!/usr/bin/env ruby
require 'roo'
require 'builder'

# Input and output file paths
excel_file = 'data/base-aerodromo-helipuertos-pub-28022025.xlsx'
output_kml_file = 'data/custom_mexican_airports.kml'

# Open the Excel file (assumes .xlsx format)
xlsx = Roo::Excelx.new(excel_file)

# Use the first sheet; adjust if your data is on a different sheet
sheet = xlsx.sheet(0)
(1..sheet.last_row).each do |i|
  next if i < 3
  row = sheet.row(i)
  # puts "Row #{i}: #{row.inspect}"
  # puts row[0]
  # exit  # Exit after printing the first row for testing
end


# Open the output file for writing the KML content
File.open(output_kml_file, "w") do |file|
  xml = Builder::XmlMarkup.new(target: file, indent: 2)
  xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
  
  xml.kml(xmlns: "http://www.opengis.net/kml/2.2") do
    xml.Document do
      xml.name("Custom Mexican Airports")

      # Iterate over rows, skipping the first two rows which contains headers.
      # Expected headers: "NO. DE EXPEDIENTE"[0], "TIPO AERÓDROMO"[1], "DESIGNADOR"[2],
      # "NOMBRE"[3], "ESTADO"[4], "MUNICIPIO"[5], "TIPO DE OPERACIÓN"[6], "TIPO DE SERVICIO"[7],
      # "NOMBRE"[8], "ELEV (M)"[9], "LATITUD\n°"[10], "LATITUD\n'"[11], "LATITUD\n''"[12],
      # "LONGITUD\n°"[13], "LONGITUD\n'"[14], "LONGITUD\n''"[15], "FECHA DE EXPEDICIÓN"[16], 
      # "DURACIÓN DEL PERMISO/  AUTORIZACIÓN"[17], "FECHA DE  VENCIMIENTO"[18], "MES"[19],
      # "AÑO"[20], "¿VIGENTE?"[21], "SITUACIÓN"[22]
      (1..sheet.last_row).each do |i|
        next if i < 3
        row = sheet.row(i)

        file_number = row[0]

        # Create a description with details about the aerodrome
        description = <<~DESC
          File Number: #{file_number}
          Aerodrome Type: #{row[1]}
          Identifier: X#{row[2]}
          Name: #{row[3]}
          State: #{row[4]}
          Municipality: #{row[5]}
        DESC
        puts description
        Process.exit

        xml.Placemark do
          xml.name(row["Name"])
          # Wrap the description in CDATA to preserve formatting
          xml.description("<![CDATA[#{description}]]>")
          xml.Point do
            # KML expects coordinates in longitude,latitude,altitude format
            xml.coordinates("#{row["Longitude"]},#{row["Latitude"]},0")
          end
        end
      end
    end
  end
end

puts "KML file created successfully: #{output_kml_file}"
