# Usage: ruby .claude/skills/afac-update/scripts/headers.rb OLD.xlsx NEW.xlsx
# Prints sheet/row/column counts and both header rows for each AFAC file,
# then a column-by-column diff of header row 2 between the first and last file.
require 'roo'

rows = ARGV.map do |f|
  x = Roo::Excelx.new(f)
  s = x.sheet(0)
  puts "== #{f}  sheets=#{x.sheets.inspect} rows=#{s.last_row} cols=#{s.last_column}"
  hdr = s.row(2).map { |v| v.to_s.gsub(/\s+/, ' ').strip }
  puts hdr.each_with_index.map { |v, i| "#{i}:#{v}" }.join(' | ')
  hdr
end

if rows.size >= 2
  a, b = rows.first, rows.last
  diffs = (0...[a.size, b.size].max).reject { |i| a[i] == b[i] }
  puts diffs.empty? ? "\nSCHEMA: identical (#{b.size} columns)" :
    "\nSCHEMA CHANGED:\n" + diffs.map { |i| "  col #{i}: #{a[i].inspect} -> #{b[i].inspect}" }.join("\n")
end
