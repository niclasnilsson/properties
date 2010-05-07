require 'facets'

module Properties
  class Property
    attr_reader :name, :kind
    
    def initialize name, kind
      @name = name
      @kind = kind
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

def property name, kind
  @__properties__ ||= {}
  @__properties__[name] = Properties::Property.new(name, kind)
  
  def __properties__
    @__properties__
  end

  
  self.send :define_method, :__set_value__ do |name, value|
    @__property_values__ ||= {}

    property = self.class.__properties__[name]
    
    c = eval property.kind.to_s.camelcase(true)
    raise Properties::PropertyError.new("Can't set value (#{value}) to property #{name} since it's not a #{kind}") if not value.kind_of?(c)
    
    @__property_values__[name] = Properties::Value.new(value, self.class.__properties__[name])
  end
  
  self.send :define_method, "#{name}=" do |value|
    __set_value__(name, value)
  end

  self.send :define_method, "#{name}" do
    @__property_values__ ||= {}
    
    return nil if @__property_values__[name].nil?
    @__property_values__[name].value 
  end
  
end
