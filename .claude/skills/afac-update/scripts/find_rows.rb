# Usage: ruby .claude/skills/afac-update/scripts/find_rows.rb FILE.xlsx COL TEXT
# Prints the X-prefixed ID, name and full COL value of every row whose column
# COL (0-based) contains TEXT (case-insensitive). Useful for picking IDs to
# pass to check_build.rb.
require 'roo'

file, col, text = ARGV[0], ARGV[1].to_i, ARGV[2].to_s.upcase
s = Roo::Excelx.new(file).sheet(0)
(3..s.last_row).each do |r|
  row = s.row(r)
  v = row[col].to_s.strip
  puts "X#{row[2].to_s.strip}  #{row[3]}  | #{v}" if v.upcase.include?(text)
end
