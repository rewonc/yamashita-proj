require 'rubygems'
require 'rmagick'

class Imagemap  
  def initialize
    @image = Magick::Image.read('5x5circle.jpg')[0]
  end  
  
  def bark  
    'Ruff! Ruff!'  
  end  

  def howl  
    return 'AwooOOOoooOOO!'  
  end 
  
  def display  
    Magick::Image.read('5x5circle.jpg')[0].each_pixel do |pixel, col, row|
      puts "Pixel at: #{col}x#{row}:
      \tR: #{pixel.red}, G: #{pixel.green}, B: #{pixel.blue}"
    end
  end  
end  


