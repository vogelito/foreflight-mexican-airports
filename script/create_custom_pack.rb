#!/usr/bin/env ruby
require 'roo'
require 'builder'

# Input and output file paths
excel_file = 'data/base-aerodromo-helipuertos-pub-28022025.xlsx'
output_kml_file = 'data/custom_mexican_airports.kml'

# Translation maps for specific fields

# Aerodrome Type translations
aerodrome_type_map = {
  "AERÓDROMO" => "Aerodrome",
  "AERÓDROMO ACUÁTICO" => "Seaplane Base",
  "AERÓDROMO HELIPUERTO" => "Heliport",
  "BARCO-HELIPUERTO" => "Heliport (Boat)",
  "HELIPUERTO" => "Heliport",
  "PLATAFORMA-HELIPUERTO" => "Heliport Platform",
  "ZONA DE DESPEGUE" => "Takeoff Zone"
}

# Type of Operation translations
operation_type_map = {
  "" => "",
  "DIRUNO" => "Daytime",      # corrected typo to Daytime
  "DIURNO" => "Daytime",
  "DIURNO Y NOCTURNO" => "Day and Night",
  "NOCTURNO" => "Night"
}

# Type of Service translations
service_type_map = {
  "" => "",
  "SERVICIO PARTICULAR" => "Private Service",
  "SERVICIO PARTICULAR / EN TRAMITE SERV. A TERCERROS" => "Private / Pending Third-Party Service",
  "SERVICIO PARTICULAR Y A TERCEROS" => "Private and Third-Party Service"
}

# Active? translations
active_map = {
  "NO" => "No",
  "SI" => "Yes"
}

# Status translations
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

# Conversion factor from meters to feet
METER_TO_FEET = 3.28084

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
      
      # Iterate over rows, skipping the first two rows (headers).
      # Expected columns (by index) and translations:
      # [0] NO. DE EXPEDIENTE         → File Number
      # [1] TIPO AERÓDROMO            → Aerodrome Type
      # [2] DESIGNADOR                → Identifier
      # [3] NOMBRE                    → Name
      # [4] ESTADO                    → State
      # [5] MUNICIPIO                 → Municipality
      # [6] TIPO DE OPERACIÓN         → Type of Operation
      # [7] TIPO DE SERVICIO          → Type of Service
      # [8] NOMBRE (alternate)        → Alternate Name
      # [9] ELEV (M)                → Elevation (M) [converted to feet]
      # [10] LATITUD °                → Latitude (Degrees)
      # [11] LATITUD '                → Latitude (Minutes)
      # [12] LATITUD ''               → Latitude (Seconds)
      # [13] LONGITUD °               → Longitude (Degrees)
      # [14] LONGITUD '               → Longitude (Minutes)
      # [15] LONGITUD ''              → Longitude (Seconds)
      # [16] FECHA DE EXPEDICIÓN      → Issue Date
      # [17] DURACIÓN DEL PERMISO/AUTORIZACIÓN → Permit/Authorization Duration
      # [18] FECHA DE VENCIMIENTO     → Expiration Date
      # [19] MES                      → Month
      # [20] AÑO                      → Year
      # [21] ¿VIGENTE?               → Active?
      # [22] SITUACIÓN                → Status

      (1..sheet.last_row).each do |i|
        next if i < 3  # Skip header rows

        row = sheet.row(i)
        
        file_number       = row[0].to_s.strip
        aerodrome_type    = row[1].to_s.strip
        identifier        = row[2].to_s.strip
        name              = row[3].to_s.strip
        state             = row[4].to_s.strip
        municipality      = row[5].to_s.strip
        type_of_operation = row[6].to_s.strip
        type_of_service   = row[7].to_s.strip
        name_alt          = row[8].to_s.strip
        elevation_m       = row[9].to_f
        lat_deg           = row[10].to_f
        lat_min           = row[11].to_f
        lat_sec           = row[12].to_f
        lon_deg           = row[13].to_f
        lon_min           = row[14].to_f
        lon_sec           = row[15].to_f
        issue_date        = row[16].to_s.strip
        permit_duration   = row[17].to_s.strip
        expiration_date   = row[18].to_s.strip
        month             = row[19].to_s.strip
        year              = row[20].to_s.strip
        active            = row[21].to_s.strip
        status            = row[22].to_s.strip
        
        # Translate fields using our mapping hashes.
        translated_aerodrome_type = aerodrome_type_map[aerodrome_type] || aerodrome_type
        translated_operation_type  = operation_type_map[type_of_operation] || type_of_operation
        translated_service_type    = service_type_map[type_of_service] || type_of_service
        translated_active          = active_map[active.upcase] || active
        translated_status          = status_map[status.upcase] || status

        # Convert elevation from meters to feet
        elevation_ft = (elevation_m * METER_TO_FEET).round(2)
        
        # Convert the DMS coordinates to decimal degrees
        decimal_latitude  = lat_deg + (lat_min / 60.0) + (lat_sec / 3600.0)
        decimal_longitude = lon_deg + (lon_min / 60.0) + (lon_sec / 3600.0)
        
        # Build a description string using translated field names and values
        description = <<~DESC
          File Number: #{file_number}
          Aerodrome Type: #{translated_aerodrome_type}
          Identifier: X#{identifier}
          Name: #{name}
          State: #{state}
          Municipality: #{municipality}
          Type of Operation: #{translated_operation_type}
          Type of Service: #{translated_service_type}
          Alternate Name: #{name_alt}
          Elevation: #{elevation_ft} ft (#{elevation_m} m)
          Latitude: #{lat_deg}° #{lat_min}' #{lat_sec}" (Decimal: #{decimal_latitude.round(6)})
          Longitude: #{lon_deg}° #{lon_min}' #{lon_sec}" (Decimal: #{decimal_longitude.round(6)})
          Issue Date: #{issue_date}
          Permit/Authorization Duration: #{permit_duration}
          Expiration Date: #{expiration_date}
          Month: #{month}
          Year: #{year}
          Active?: #{translated_active}
          Status: #{translated_status}
        DESC

        # Create a Placemark for this aerodrome
        xml.Placemark do
          xml.name(name)
          # Wrap the description in CDATA to preserve formatting and special characters
          xml.description("<![CDATA[#{description}]]>")
          xml.Point do
            # KML coordinates are "longitude,latitude,altitude" (altitude set to 0)
            xml.coordinates("#{decimal_longitude},#{decimal_latitude},0")
          end
        end
      end
    end
  end
end

puts "KML file created successfully: #{output_kml_file}"
