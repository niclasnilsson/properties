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

describe "a collection property" do
  cleanup.after_spec

  before do
    class Computer
      collection :audio_inputs, :string
    end
    @computer = Computer.new
  end

  it "should be empty by default" do
    @computer = Computer.new.audio_inputs.should == []
  end

  it "accepts appending of values" do
    @computer.audio_inputs << "line in"
    @computer.audio_inputs << "built-in microphone"

    @computer.audio_inputs.should == ["line in", "built-in microphone"]
    @computer.audio_inputs.should == ["line in", "built-in microphone"]
    @computer.audio_inputs()[0].should == "line in"
    @computer.audio_inputs()[1].should == "built-in microphone"
  end
  
  it "accepts replacing of entire collection" do
    @computer.audio_inputs << "line in"
    @computer.audio_inputs << "microphone"

    # Overwrite the entire collection
    @computer.audio_inputs = ["usb microphone #1", "usb microphone #2"]

    @computer.audio_inputs.should == ["usb microphone #1", "usb microphone #2"]
  end

  it "convert replacing entire collection with nil to an empty collection" do
    @computer.audio_inputs << "line in"
    @computer.audio_inputs.size == 1
    @computer.audio_inputs = nil
    @computer.audio_inputs.should == []
  end
  
  it "should reject appending values of wrong type" do
    pending "This needs to hijack the << method on the object (singleton class) or similar"
    lambda { @computer.audio_inputs << 1 }.should raise_error(Properties::PropertyError)
  end

  it "should reject overwrite of entire collection if new collection contains elements of wrong type" do
    lambda { @computer.audio_inputs = ["line in", 23] }.should raise_error(Properties::PropertyError)
  end

end

describe "nested complex types" do

  cleanup.after_spec

  before do
    class Partition 
     property :name, :string
    end

    class Disk
     property :name, :string
     property :gigabytes, :integer
     collection :partitions, :partition
    end


    class Computer
      property :name, :string
      collection :disks, :Disk

    end
    @computer = Computer.new
  end

  it "should work on collections" do
    @computer.name = "My Computer"
    @computer.disks.should == []
    disk0 = Disk.new
    disk0.name = "First disk"
    disk0.gigabytes = 200

    partition0 = Partition.new
    partition0.name = "p0"
    partition1 = Partition.new
    partition1.name = "p1"

    
    disk1 = Disk.new
    disk1.name = "Second disk"
    disk1.gigabytes = 300
    disk1.partitions = [ partition0, partition1 ]


    @computer.disks = [ disk0, disk1 ]

    @computer.name.should == "My Computer"
    @computer.disks[0].name.should == "First disk"
    @computer.disks[0].gigabytes.should == 200
    @computer.disks[1].name.should == "Second disk"
    @computer.disks[1].gigabytes.should == 300
    
    @computer.disks[1].partitions[0].name.should == "p0"
  end
end

