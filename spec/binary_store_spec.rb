require 'spec_helper'
require 'state_store'

describe StateStore::BinaryStore do 
  let(:klass){StateStore::BinaryStore}

  it "should create new store instance with statuses" do 
    expect{
      klass.new([])
      klass.new([:read])
      klass.new([:read,:write])
    }.not_to raise_error
  end

  it "it should raise error when statuses not Array" do 
    expect{
      klass.new(Object.new)
    }.to raise_error(ArgumentError,"Only array is accepted.")
  end

  describe "attributes" do 
    let(:statuses){[:one,:two,:five]}
    it "should assign received statuses to statuses" do 
      store = klass.new(statuses)
      store.statuses.should eq(statuses)
    end

    it "should assign states statuses size" do 
      store = klass.new(statuses)
      store.states.should eq(statuses.size)
    end

    it "should calculate and assign total positions to total_positions" do 
      store = klass.new(statuses)
      store.total_positions.should eq((2**statuses.size)-1)
    end
  end

  it "should convert value to array with matching human statuses" do 
    store = klass.new([:read,:write,:execute])
    store.humanize(0).should eq([])
    store.humanize(1).should eq([:execute])
    store.humanize(2).should eq([:write])
    store.humanize(3).should eq([:write,:execute])
    store.humanize(4).should eq([:read])
    store.humanize(5).should eq([:read,:execute])
    store.humanize(6).should eq([:read,:write])
    store.humanize(7).should eq([:read,:write,:execute])
  end

  it "should raise error when given value is greated then store total positions" do 
    store = klass.new([:one])
    expect{
      store.humanize(2)
    }.to raise_error(ArgumentError,"Out of range")
  end

  it "should detect if value include given status" do 
    store = klass.new([:read,:write,:execute])
    store.has_status?(:read,5).should be_true
    store.has_status?(:read,3).should be_false
  end

  it "should return human status for given index when given state is '1'" do 
    store = klass.new([:one,:two])
    store.index(1,"1").should eq(:two)
    store.index(1,"0").should be_nil
  end
end