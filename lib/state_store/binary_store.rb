require 'observer'

module StateStore
  class BinaryStore
    attr_reader :statuses, :states, :total_positions

    def initialize(statuses)
      raise ArgumentError.new("Only array is accepted.") unless statuses.is_a?(Array)
      @statuses = statuses
      @states = statuses.size
      @total_positions = 2**@states-1
    end

    def humanize(value)
      raise ArgumentError.new("Out of range") if self.total_positions < value
      humanized_array = value_to_statuses(value)
      humanized_array.extend(HumanizedArrayOperations)
      humanized_array
    end

    def value(humanized_array) 
      raise ArgumentError.new("Out of range") if self.states < humanized_array.size
      statuses_to_values(humanized_array)
    end
 
    def has_status?(symbol,value) 
      human_array = humanize(value)
      human_array.include?(symbol)
    end

    def index(index,state)
      statuses[index] if state.to_s == "1"
    end

    def index_by_state(state)
      statuses[state]
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
