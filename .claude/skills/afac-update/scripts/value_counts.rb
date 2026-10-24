# Usage: ruby .claude/skills/afac-update/scripts/value_counts.rb FILE.xlsx COL [COL2]
# Counts each distinct value in column COL (0-based). With COL2, breaks each
# COL value down by the values of COL2 (e.g. service type by aerodrome type).
require 'roo'

file, col, col2 = ARGV[0], ARGV[1].to_i, ARGV[2]&.to_i
s = Roo::Excelx.new(file).sheet(0)
counts = Hash.new { |h, k| h[k] = Hash.new(0) }
(3..s.last_row).each do |r|
  row = s.row(r)
  counts[row[col].to_s.strip][col2 ? row[col2].to_s.strip : ''] += 1
end

counts.sort_by { |_, sub| -sub.values.sum }.each do |val, sub|
  puts "#{sub.values.sum.to_s.rjust(5)}  #{val.inspect}"
  next unless col2
  sub.sort_by { |_, n| -n }.each { |v2, n| puts "         #{n.to_s.rjust(5)}  #{v2.inspect}" }
end
