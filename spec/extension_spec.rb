require 'spec_helper'
require 'state_store'

describe StateStore::Extension do
  let(:klass){Class.new}
  
  it "should add #has_store class method" do 
    klass.send(:include,StateStore)
    klass.should.respond_to?(:has_store)
  end

  describe "ClassMethods" do 
    before(:each) do 
      klass.send(:include,StateStore)
    end

    it "should raise error when no statuses is given" do 
      expect{
        klass.has_statuses()
      }.to raise_error(ArgumentError,"No statuses given")
    end

    it "should raise error when no :in key is given" do 
      expect{
        klass.has_statuses :read,:write
      }.to raise_error(ArgumentError,":in is required")
    end

    it "should create store with given statuses" do 
      klass.has_statuses :read,:write, :in => :status
      klass.state_store_store.statuses.should eq([:read,:write])
    end

    it "should store given options in #state_store_options" do 
      klass.has_statuses :read,:write, :in => :status 
      klass.state_store_options.should eq({:in => :status})
    end
  end

  describe "InstanceMethods" do 
    let(:object){klass.new}
    before(:each){
      klass.class_eval do 
        def status_name
          5
        end
      end
      klass.send(:include,StateStore)
    }

    it "should call store #has_status? when #has_status_name? is called on klass instance" do 
      klass.has_statuses :read,:write,:execute, :in => :status_name
      klass.any_instance.stub(:status_name).and_return(5)
      
      object.has_status_name?(:read).should be_true
      object.has_status_name?(:write).should be_false
    end

    it "should call store #humanize when [status_name] is called on instance of class" do 
      klass.has_statuses :read,:write,:execute, :in => :status_name
      object.status_name.should eq([:read,:execute])
    end 

    it "should call super if base class not respond to method" do 

    end
  end

end