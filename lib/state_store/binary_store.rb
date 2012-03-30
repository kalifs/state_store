require 'observer'

module StateStore
  # This class provides convertation between Array to binary number and vice versa.
  # Each instance of class have its own set of statuses. 
  class BinaryStore
    attr_reader :statuses, :states, :total_positions

    def initialize(statuses)
      raise ArgumentError.new("Only array is accepted.") unless statuses.is_a?(Array)
      @statuses = statuses
      @states = statuses.size
      @total_positions = 2**@states-1
    end

    # Method receives value and return Array of statuses that matches current number.
    def humanize(value)
      raise ArgumentError.new("Out of range") if self.total_positions < value
      humanized_array = value_to_statuses(value)
      humanized_array.extend(HumanizedArrayOperations)
      humanized_array
    end

    # Method receives Array of statuses and create binary number that respresents this status for store statuses set.
    # =====Example
    #      store = StateStore.new([:read,:write,:execute])
    #      store.value([:read,:execute]) # will be interpreted as 101 or 5
    #      store.value([:write,:execute]) # will be interpreted as 011 or 3
    def value(humanized_array) 
      raise ArgumentError.new("Out of range") if self.states < humanized_array.size
      statuses_to_values(humanized_array)
    end
 
    # It receives status and value and check if given value match given status.
    # =====Example
    #      store = StateStore.new([:read,:write,:execute])
    #      store.has_status?(:read,4) # will be false because 4 is for :write only
    #      store.has_status?(:read,5) # will be true because 5 is for :read and :execute
    def has_status?(symbol,value) 
      human_array = humanize(value)
      human_array.include?(symbol)
    end

    # This method receives index and state and will retrun status with given index if state is "1"
    def index(index,state)
      statuses[index] if state.to_s == "1"
    end

    private

    def value_to_statuses(value)
      result = []
      normalized_array(value_to_binary_array(value)).each_with_index do |state,index|
        if current_status = index(index,state)
          result << current_status
        end
      end
      result
    end

    def statuses_to_values(statuses_array)
      self.statuses.map do |status|
        statuses_array.include?(status) ? "1" : "0"
      end.join("").to_i(2)
    end

    def normalized_array(array)
      (Array.new(self.states - array.size, "0")+ array)
    end

    def value_to_binary_array(value)
      value.to_s(2).split("")
    end

    module HumanizedArrayOperations
      include Observable

      def add(*args)
        changed
        args.each do |value|
          self << value
        end
        notify_observers(self)
      end

      def remove(*args)
        changed
        args.each do |value|
          self.delete(value)
        end
        notify_observers(self)
      end
    end

    class BinaryValue
      attr_reader :value,:store

      def initialize(store,value)
        @value = value
        @store = store
      end

      def has_status?(symbol)
        self.store.has_status?(symbol,self.value)
      end
    end
  end
end
