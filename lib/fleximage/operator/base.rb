module Fleximage
  module Operator
    
    class BadOperatorResult < Exception #:nodoc:
    end
    
    class OperationNotImplemented < Exception #:nodoc:
    end
    
    # The Operator::Base class is what all other Operator classes inherit from.
    # To write your own Operator class, simply inherit from this class, and 
    # implement your own operate methods, with your own arguments.  Just 
    # return a new RMagick image object that represents the new image, and
    # the model will be updated automatically.
    #
    # You have access to a few instance variables in the operate method:
    #
    # * @image : The current image from the model.  Use this is a starting 
    #   point for all transformations.
    # * @model : The model instance that this image transformation is happenining
    #   in.  Use it to get data out of your model for display in your image.
    class Base
      # Create a operator, capturing the model object to operate on
      def initialize(proxy, image, model_obj) #:nodoc:
        @proxy = proxy
        @image = image
        @model = model_obj
      end
      
      # Start the operation
      def execute(*args) #:nodoc:
        # Get the result of the Operators #operate method
        result = operate(*args)
        
        # Ensure that the result is an RMagick:Image object
        unless result.is_a?(Magick::Image)
          raise BadOperatorResult, "expected #{self.class}#operate to return an instance of Magick::Image. \n"+
                                   "Got instance of #{result.class} instead."
        end
        
        # Save the result to the operator proxy
        @proxy.image = result
      end
      
      # Perform the operation.  Override this method in your Operator::Base subclasses
      # in order to write your own image operators.
      def operate(*args)
        raise OperationNotImplemented, "Override this method in your own subclass."
      end
      
      # ---
      # - SUPPORT METHODS
      # ---
      
      # Converts a size object to an [x,y] array.  Acceptible formats are:
      # 
      # * 10
      # * "10"
      # * "10x20"
      # * [10, 20]
      #
      # Usage:
      #
      #   x, y = size_to_xy("10x20")
      def size_to_xy(size)
        case          
        when size.is_a?(Array) && size.size == 2  # [320, 240]
          size
      
        when size.to_s.include?('x')              # "320x240"
          size.split('x').collect(&:to_i)
        
        else # Anything else, convert the object to an integer and assume square dimensions
          [size.to_i, size.to_i]
          
        end
      end
      
      # Scale the image, respecting aspect ratio.  
      # Operation will happen in the main <tt>@image</tt> unless you supply the +img+ argument
      # to operate on instead.
      def scale(size, img = @image)
        img.change_geometry!(size_to_xy(size).join('x')) do |cols, rows, _img|
          cols = 1 if cols < 1
          rows = 1 if rows < 1
          _img.resize!(cols, rows)
        end
      end
      
      # Scale to the desired size and crop edges off to get the exact dimensions needed.
      # Operation will happen in the main <tt>@image</tt> unless you supply the +img+ argument
      # to operate on instead.
      def scale_and_crop(size, img = @image)
        img.crop_resized!(*size_to_xy(size))
      end
      
      # Resize the image, with no respect to aspect ratio.  
      # Operation will happen in the main <tt>@image</tt> unless you supply the +img+ argument
      # to operate on instead.
      def stretch(size, img = @image)
        img.resize!(*size_to_xy(size))
      end
      
      # Convert a symbol to an RMagick blending mode.
      # 
      # The blending mode governs how the overlay gets composited onto the image.  You can 
      # get some funky effects with modes like :+copy_cyan+ or :+screen+.  For a full list of blending
      # modes checkout the RMagick documentation (http://www.simplesystems.org/RMagick/doc/constants.html#CompositeOperator).
      # To use a blend mode remove the +CompositeOp+ form the name and "unserscorize" the rest.  For instance,
      # +MultiplyCompositeOp+ becomes :+multiply+, and +CopyBlackCompositeOp+ becomes :+copy_black+.
      def symbol_to_blending_mode(mode)
        "Magick::#{mode.to_s.camelize}CompositeOp".constantize
      rescue NameError
        raise ArgumentError, ":#{mode} is not a valid blending mode."
      end
        
        
    end # Base
    
    # Conversion table for mapping alignment symbols to their equivalent RMagick gravity constants.
    GRAVITIES = {
      :center       => Magick::CenterGravity,
      :top          => Magick::NorthGravity,
      :top_right    => Magick::NorthEastGravity,
      :right        => Magick::EastGravity,
      :bottom_right => Magick::SouthEastGravity,
      :bottom       => Magick::SouthGravity,
      :bottom_left  => Magick::SouthWestGravity,
      :left         => Magick::WestGravity,
      :top_left     => Magick::NorthWestGravity,
    } unless defined?(GRAVITIES)
    
  end # Operator
end # Fleximage