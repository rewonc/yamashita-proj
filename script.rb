require 'rubygems'
require 'rmagick'
require 'delegate'

class PixelDecorator < SimpleDelegator
  def rgb
    lightness = (red/65535.0 * 0.2126) + (green/65535.0 * 0.7152) + (blue/65535.0 * 0.0722)
    (lightness * 100).round
  end
end

class Imagemap  
  def initialize
    @path = '5x5circle.jpg'
    @magick = Magick::Image.read('public/' + @path)
  end  

  def image
    @magick[0]
  end

  def path
    '/' + @path
  end

  def dimensions
    "This image is #{image.columns}x#{image.rows} pixels"
  end
  
  def rgbmap
    map = Array.new
    image.each_pixel do |pixel, col, row|
      if map[row].kind_of?(Array)
        map[row][col] = PixelDecorator.new(pixel)
      else 
        map[row] = Array.new
        map[row][col] = PixelDecorator.new(pixel)
      end
    end  
    map
  end  
  
  def display  
    Magick::Image.read('5x5circle.jpg')[0].each_pixel do |pixel, col, row|
      puts "Pixel at: #{col}x#{row}:
      \tR: #{pixel.red}, G: #{pixel.green}, B: #{pixel.blue}"
    end
  end  
end  


