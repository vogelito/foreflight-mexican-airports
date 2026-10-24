# Usage: ruby .claude/skills/afac-update/scripts/check_build.rb NEW.xlsx [ID ...]
# Run after script/create_custom_pack.rb. Prints the source data-row count, the
# placemark counts in both generated KMLs, and for each ID (e.g. XGRN) its KML
# coordinates and icon style next to the raw DMS/status values from the source.
require 'roo'

xlsx, *ids = ARGV
s = Roo::Excelx.new(xlsx).sheet(0)
rows = (3..s.last_row).map { |r| s.row(r) }
kml = { 'airports' => File.read('data/custom_mexican_airports.kml'),
        'heliports' => File.read('data/custom_mexican_heliports.kml') }

counts = kml.transform_values { |k| k.scan('<Placemark>').size }
puts "source data rows: #{rows.size}"
puts "placemarks: #{counts.map { |n, c| "#{n}=#{c}" }.join(' ')} total=#{counts.values.sum}"
styles = kml.values.join.scan(/<styleUrl>#(.*?)<\/styleUrl>/).flatten.tally.sort
puts "icons: #{styles.map { |st, c| "#{st}=#{c}" }.join(' ')}"

all = kml.values.join
ids.each do |id|
  src = rows.find { |row| "X#{row[2].to_s.strip}" == id }
  raw = src ? "lat #{src[13..15].join(' ')} / lon #{src[16..18].join(' ')}, status #{src[30].inspect}" : 'not in source'
  i = all.index("<name>#{id}</name>")
  if i
    seg = all[i, 8000]
    puts "#{id}: #{seg[/<coordinates>(.*?)<\/coordinates>/, 1]} #{seg[/<styleUrl>(.*?)<\/styleUrl>/, 1]} | source: #{raw}"
  else
    puts "#{id}: not in KML | source: #{raw}"
  end
end
