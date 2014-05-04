require 'rubygems'
require 'rmagick'
require 'delegate'

#one method: set the nails beforehand
#another method: set the nails later. why not do that? Just build off pixels.
#make it so that new vertices come from the photo. Why make it fit to a grid?
#how to figure out the best vertices?
#right now, with our 30 pts we have 900 possible lines. Hrm. Thats actually
#not that much, as we must necessarily take a subset.
#If we don't have flexibility in the vertices, that might not be enough.
#We could also make the math for the lines go from the vertices of the pixel
#each pixel would have four sides or four points that would be the starting pts
#would replicate the geometry of the nails.

#making the grid:
#we'd want the max darkness value between all the combined pts
#that still could hit every pixel
#right? The current grid doesn't hit every pixel I think. 

class PixelDecorator < SimpleDelegator
  def initialize(obj)
    super
    @count = 0
  end

  def rgb
    # see http://stackoverflow.com/questions/687261/converting-rgb-to-grayscale-intensity
    lightness = (red/65535.0 * 0.2126) + (green/65535.0 * 0.7152) + (blue/65535.0 * 0.0722)
    percentage = (lightness * 100).round
    100 - percentage
  end

  def available_moves
    rgb - @count
  end

  def cross
    @count = @count + 1
  end 

  def count
    @count
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
    @history = Array.new
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
    return [] if z === 0
    x_increment = Rational(x,z)
    y_increment = Rational(y,z)
    for i in 1..z do
      c = (pt1[0] + i * x_increment).round
      r = (pt1[1] + i * y_increment).round
      arr << [@map[r-1][c-1], c, r] if !@map[r-1][c-1].nil?
    end
    arr << [@map[pt1[1]-1][pt1[0]-1], pt1[0], pt1[1]]
    arr << [@map[pt2[1]-1][pt2[0]-1], pt2[0], pt2[1]]
    #reduce duplication here somehow. this is a problem.
    arr
  end

  def line_options(startpt)
    arr = []
    @grid.array.each do |point|
      arr << line_pixels(startpt, point) unless line_pixels(startpt,point).map{|x|x[0].available_moves}.include?(0)
    end
    arr
  end

  def best_line(startpt)
    x = line_options(startpt)
    x.max_by do |element|
      element.map{|y| [y[1],y[2]]}.uniq.length
    end
    # need to return uniqs so they dont get counted twice by draw line
  end

  def draw_line(startpt)
    best_line(startpt).each do |point|
      @map[point[2]-1][point[1]-1].cross unless @map[point[2]][point[1]].nil?
    end
    return [best_line(startpt).last[1],best_line(startpt).last[2]]
  end

  def draw_lines(startpt, number)
    i = 0
    while i < number
      startpt = draw_line(startpt)
      i = i + 1
    end
    @map
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




