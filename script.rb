require 'rubygems'
require 'rmagick'
require 'delegate'

class PixelDecorator < SimpleDelegator
  def rgb
    # see http://stackoverflow.com/questions/687261/converting-rgb-to-grayscale-intensity
    lightness = (red/65535.0 * 0.2126) + (green/65535.0 * 0.7152) + (blue/65535.0 * 0.0722)
    percentage = (lightness * 100).round
    100 - percentage
  end
end

class Grid < SimpleDelegator
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

class Linemapper
  def initialize(map, grid)
    @map = map
    @grid = grid
  end

  def check(pt1,pt2)
    if !@grid.array.include?(pt1) || !@grid.array.include?(pt2)
      return "pt1 or pt2 are not included nail array pts"
    end

    rise = pt2[1] - pt1[1]
    run = pt2[0] - pt1[0]
    rise != 0 ? slope = Rational(run, -rise) : slope = 'infinity'
    #"run #{run}, fall #{rise}, slope is #{slope.to_s}"
  end

  def line_pixels(pt1, pt2)
    arr = []
    x = pt2[0] - pt1[0]
    y = pt2[1] - pt1[1]
    z = hypotenuse(pt1,pt2)
    return 'no slope' if z === 0
    x_increment = Rational(x,z)
    y_increment = Rational(y,z)
    for i in 1..z do
      arr << [(pt1[0] + i * x_increment).round, (pt1[1] + i * y_increment).round]
    end
    arr.uniq
  end

  def hypotenuse(pt1, pt2)
    hypotenuse = Math.sqrt((pt2[1] - pt1[1])**2 + (pt2[0] - pt1[0])**2).round
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
  
  def grid  
    Grid.new(image)
  end  

  def linemapper
    Linemapper.new(rgbmap, grid)
  end
end  




