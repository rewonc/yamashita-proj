require 'rubygems'
require 'rmagick'

class Imagemap  
  def initialize
    @path = '5x5circle.jpg'
    @magick = Magick::Image.read(@path)
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
  
  def pixelmap
    
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


