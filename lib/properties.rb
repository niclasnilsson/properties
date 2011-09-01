require 'facets'
 
module Properties
  class Property
    attr_reader :name, :kind, :is_collection
   
    def initialize name, kind, is_collection
      @name = name
      @kind = kind
      @is_collection = is_collection
    end
  end
end
 
module Properties
  class Value
    attr_reader :property
    attr_accessor :value
   
    def initialize value, property
      @value = value
      @property = property
    end
  end
end
 
module Properties
  class PropertyError < RuntimeError
  end
end
 
def property name, kind, is_collection = false
  classname = eval kind.to_s.camelcase

  @__properties__ ||= {}
  @__properties__[name] = Properties::Property.new(name, kind, is_collection)
  @is_collection = is_collection
 
  def __properties__
   @__properties__
  end
 

  if is_collection
    code = "
      def #{name}
        @#{name} ||= []
        @#{name}
      end
    " 
    eval code

    code = "
      def #{name}=(values)
        values ||= []
        values.each do |value|
          raise Properties::PropertyError.new(\"Can't set value (\#{value.inspect}) to property #{name} since not all elements are a #{classname}\") if not value.kind_of?(#{classname})
        end

        @#{name} = values
      end
    "
    eval code

  else
    code = "
      def #{name}
        @#{name}
      end
    " 
    eval code

    code = "
      def #{name}=(value)
        raise Properties::PropertyError.new(\"Can't set value (\#{value}.inspect) to property #{name} since it's not a #{classname}\") if not value.kind_of?(#{classname})
        @#{name} = value
      end
    "
    eval code
  end
  
end
 
def collection name, kind
  property name, kind, true
end


