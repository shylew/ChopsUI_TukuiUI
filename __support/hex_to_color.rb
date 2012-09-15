#!/usr/bin/env ruby

hex_color = ARGV[0]
if hex_color.nil? || hex_color.strip == ""
  puts "Usage: hex_to_color.rb <hex color code>"
  exit 1
end

if hex_color.length == 6 && hex_color =~ /^[0-9a-f]+$/i

  colors = []

  (0..5).step(2) do |i|
    decimal_color = hex_color[i..i+1].to_i(16).to_f / 255
    colors << (decimal_color * 10**2).round.to_f / 10**2
  end

  puts colors.join(", ")

else
  puts "Invalid hex color code"
  exit 1
end
