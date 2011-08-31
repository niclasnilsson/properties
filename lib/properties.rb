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
  @__properties__ ||= {}
  @__properties__[name] = Properties::Property.new(name, kind, is_collection)
  @is_collection = is_collection
 
  def __properties__
   @__properties__
  end
   
  self.send :define_method, :__set_value__ do |name, value|
    @__property_values__ ||= {}
 
    property = self.class.__properties__[name]
 
    c = eval property.kind.to_s.camelcase

    if property.is_collection 
      value.all? { |v| v.kind_of?(c) } 
    else
      raise Properties::PropertyError.new("Can't set value (#{value}) to property #{name} since it's not a #{kind}") if not value.kind_of?(c)
    end

    @__property_values__[name] = Properties::Value.new(value, self.class.__properties__[name])
  end

  if is_collection
    # Create a getter
    self.send :define_method, "#{name}" do
      @__property_values__ ||= {}
     
      __set_value__(name, []) if @__property_values__[name].nil?
      @__property_values__[name].value
    end

    # Create a setter
    self.send :define_method, "#{name}=" do |value|
      __set_value__(name, value)
    end
  else
    # Create a getter
    self.send :define_method, "#{name}" do
      @__property_values__ ||= {}
     
      return nil if @__property_values__[name].nil?
      @__property_values__[name].value
    end

    # Create a setter
    self.send :define_method, "#{name}=" do |value|
      __set_value__(name, value)
    end
   
  end
end
 
def collection name, kind
  property name, kind, true
end


