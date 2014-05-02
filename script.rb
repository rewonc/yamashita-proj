require 'rubygems'
require 'rmagick'

Magick::Image.read('5x5circle.jpg')[0].each_pixel do |pixel, col, row|
  puts "Pixel at: #{col}x#{row}:
  \tR: #{pixel.red}, G: #{pixel.green}, B: #{pixel.blue}"
end