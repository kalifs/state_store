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

    it "should raise error when no states is given" do 
      expect{
        klass.has_states()
      }.to raise_error(ArgumentError,"No states given")
    end

    it "should raise error when no :in key is given" do 
      expect{
        klass.has_states :read,:write
      }.to raise_error(ArgumentError,":in is required")
    end

    it "should create scope in class for each state store by default with name :states" do 
      klass.has_states :read,:write, :in => :status
      klass.states_stores.keys.should eq([:states])
      klass.has_states :green,:round, :in => :other_status, :as => :properties
      klass.states_stores.keys.sort.should eq([:properties,:states])
    end

    it "should validate if there is scope with same name" do 
      klass.has_states :read,:write, :in => :status
      expect{
        klass.has_states :green, :round, :in => :other_status
      }.to raise_error(ArgumentError, "Scope 'states' already exists")
    end   

    it "should validate if there is scope with same storage attribute" do 
      klass.has_states :read,:write, :in => :status
      expect{
        klass.has_states :green, :round, :in => :status, :as => :properties
      }.to raise_error(ArgumentError, "Scope 'states' already store configuration in 'status'")
    end

    it "should create store with given statuses" do 
      klass.has_states :read,:write, :in => :status
      klass.states_stores[:states].statuses.should eq([:read,:write])
    end

    it "should store given options in #state_store_options" do 
      klass.has_states :read,:write, :in => :status 
      klass.states_stores_options[:states].should eq({:in => :status, :as => :states})
    end
  end

  describe "InstanceMethods" do 
    let(:object){klass.new}
    before(:each){
      klass.class_eval do 
        def status_name
          @status_name || 5
        end
      end
      klass.send(:include,StateStore)
    }

    it "should call store #has_status? when #has_status_name? is called on klass instance" do 
      klass.has_states :read,:write,:execute, :in => :status_name
      klass.any_instance.stub(:status_name).and_return(5)
      
      object.has_status_name?(:read).should be_true
      object.has_status_name?(:write).should be_false
    end

    it "should call store #humanize when [status_name] is called on instance of class" do 
      klass.has_states :read,:write,:execute, :in => :status_name
      object.states.should eq([:read,:execute])
    end 

    it "should assign value from array to status method" do 
      klass.has_states :read, :write, :execute, :in => :status_name
      klass.class_eval do 
        def status_name=(value)
          @status_name = value
        end
      end
      object.states= [:read,:write]
      object.status_name.should eq(6)
    end
 
    context "observation" do 
      before(:each) do 
        klass.class_eval do 
          def status_name=(value)
            @status_name = value
          end
        end
        klass.has_states :read,:write,:execute, :in => :status_name
      end

      it "should change storage attribute when state is added to states array" do 
        object.states.add(:write)
        object.status_name.should eq(7)
      end

      it "should change storage attribute when state is removed from states array" do 
        object.states.remove(:read)
        object.status_name.should eq(1)
      end
    end
  end

end