require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rspec-cleanup'

describe "a property" do
  cleanup.after_spec
  
  it "should have a name and a type" do
    class Computer
      property :name, :string
    end
  end
  
  before do
    class Person
      property :name, :string
    end

    @person = Person.new
  end

  describe "should have a set accessor that" do
    it "accepts values of the specified type" do
      @person.name = "Niclas"
    end

    it "rejects values of other types" do
      lambda { @person.name = 1 }.should raise_error(Properties::PropertyError)
    end
  end
  
  describe "should have a get accessor that" do
    it "returns the value of the property" do
      @person.name = "Niclas"
      @person.name.should == "Niclas"
    end

    it "returns nil if property has not been set" do
      Person.new.name.should == nil
    end
  end
end


