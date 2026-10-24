# Usage: ruby .claude/skills/afac-update/scripts/new_values.rb OLD.xlsx NEW.xlsx
# Lists category values that appear in NEW but not OLD (case-insensitive), with
# the rows that use them. Each one needs an entry in the matching translation
# map in script/create_custom_pack.rb, or it will show up in Spanish.
require 'roo'

COLS = { 1 => 'type', 6 => 'operation', 7 => 'service', 8 => 'classification',
         23 => 'surface', 25 => 'duration', 30 => 'status' }

def load(path)
  s = Roo::Excelx.new(path).sheet(0)
  (3..s.last_row).map { |r| [r, s.row(r)] }
end

old_vals = Hash.new { |h, k| h[k] = [] }
load(ARGV[0]).each { |_, row| COLS.each_key { |c| old_vals[c] << row[c].to_s.strip.upcase } }

found = Hash.new { |h, k| h[k] = [] }
load(ARGV[1]).each do |r, row|
  COLS.each_key do |c|
    v = row[c].to_s.strip
    found[c] << "row #{r}: #{v.inspect} [#{row[2]} #{row[3]}]" unless v.empty? || old_vals[c].include?(v.upcase)
  end
end

COLS.each do |c, name|
  puts found[c].empty? ? "#{name}: no new values" : "#{name}:\n  " + found[c].join("\n  ")
end
