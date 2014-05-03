require 'rubygems'
require 'rmagick'
require 'delegate'

=begin
So the photo is around 600 pixels wide and 700 pixels high
Say I want the nails every half inch. 
I also see the end product being like 2 ft x 3 ft. 
That means I have 24 x 28 nails. 
Or, approximately 25 pixels per nail.
25 x 25 pixels per nail. 
If that's the nail grid, it seems like if the board were 25x25 nail grids
it would allow for maximum extension from the edge grids.

Hmm. what does it look like from the middle?
=end

class PixelDecorator < SimpleDelegator
  def rgb
    # see http://stackoverflow.com/questions/687261/converting-rgb-to-grayscale-intensity
    lightness = (red/65535.0 * 0.2126) + (green/65535.0 * 0.7152) + (blue/65535.0 * 0.0722)
    percentage = (lightness * 100).round
    100 - percentage
  end
end

class GraphDecorator < SimpleDelegator
  
  def initialize(image)
    super
    @x_spacing = Math.sqrt(columns).round.to_i
    @y_spacing = Math.sqrt(rows).round.to_i
    x_mod = columns - @x_spacing*@x_spacing
    y_mod = rows - @y_spacing*@y_spacing
    if x_mod >= 0
      @x_columns = @x_spacing
    else
      @x_columns = @x_spacing - 1
    end
    if y_mod >= 0
      @y_rows = @y_spacing
    else
      @y_rows = @y_spacing - 1
    end
  end

  def spacing
    "You'll have a #{@x_spacing}x#{@y_spacing} set of pixels between nails. There are #{@x_columns} columns and #{@y_rows} rows of nails"
  end

  def array
    arr = []
    (0..@x_columns).each do |column|
      (0..@y_rows).each do |row|
        arr << [column*@x_spacing + 1, row*@y_spacing + 1]
      end
    end
    arr
  end

  def first_point
    array[0]
  end
end

class Imagemap  
  def initialize(path)
    @path = path
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
  
  def graph  
    GraphDecorator.new(image)
  end  

end  


