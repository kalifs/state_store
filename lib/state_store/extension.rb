module StateStore
  module Extension

    module ClassMethods

      def has_states *states
        state_store_options = states && states.last.is_a?(Hash) && states.pop || {}
        raise ArgumentError.new("No states given") if states.empty? 
        raise ArgumentError.new(":in is required") unless state_store_options[:in]

        state_store_options[:as] ||= :states
        store = StateStore::BinaryStore.new(states)

        @states_stores ||={}
        @states_stores_options ||={}

        @states_stores[state_store_options[:as]] = store
        @states_stores_options[state_store_options[:as]] = state_store_options
        create_methods_for_state_store(state_store_options[:as])
      end 

      def states_stores
        @states_stores
      end

      def states_stores_options
        @states_stores_options
      end

      private

      def create_methods_for_state_store(name)

        self.class_eval do 
          define_method name do 
            method_name = self.class.states_stores_options[name][:in]
            value = self.send(method_name)
            self.class.states_stores[name].humanize(value)
          end

          define_method :"#{name}=" do |humanized_array|
            method_name = self.class.states_stores_options[name][:in]
            store = self.class.states_stores[name]
            self.send(:"#{method_name}=",store.value(humanized_array))
          end
        end

      end
    end

    module InstanceMethods
      def self.included(base)
        def method_missing(method_name, *args)
          state_method_name = method_name.to_s.match(/^has_(\w+)\?$/)
          state_method_name = state_method_name && state_method_name[1].to_sym
          if state_method_name
            options = self.class.states_stores_options.detect{|key,value| value[:in].to_sym == state_method_name}
            options = options && options[1]
            if options
              instance_method_name = options && options[:in]
              self.class.states_stores[options[:as]].has_status?(args[0],self.send(instance_method_name))
            else
              super
            end
          else
            super
          end
        end 
      end
    end
  end
end