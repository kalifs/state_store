require 'spec_helper'
require 'state_store'

describe StateStore::BinaryStore::BinaryValue do 
  let(:store){double("store")}
  let(:klass){StateStore::BinaryStore::BinaryValue}

  it "should create new with store and value" do 
    expect{
      klass.new(store,4)
    }.not_to raise_error
  end

  describe "attributes" do 
    it "should have value" do 
      value = klass.new(store,4)
      value.value.should eq(4)
    end

    it "should have store" do 
      value =klass.new(store,4)
      value.store.should eq(store)
    end
  end

  it "should detect if it has status" do 
    value = klass.new(store,4)
    store.should_receive(:has_status?).with(:read,4)
    value.has_status?(:read)
  end
end