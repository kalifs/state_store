module StateStore
  module Extension

    module ClassMethods

      def has_states *states
        states_stores_options = states && states.last.is_a?(Hash) && states.pop || {}
        raise ArgumentError.new("No states given") if states.empty? 
        raise ArgumentError.new(":in is required") unless states_stores_options[:in]

        states_stores_options[:as] ||= :states
        store = StateStore::BinaryStore.new(states)

        @states_stores ||={}
        @states_stores_options ||={}
        validate_state_store(states_stores_options)

        @states_stores[states_stores_options[:as]] = store
        @states_stores_options[states_stores_options[:as]] = states_stores_options
        create_methods_for_state_store(states_stores_options[:as])
      end 

      def states_stores
        @states_stores
      end

      def states_stores_options
        @states_stores_options
      end

      private

      def validate_state_store(options)
        raise ArgumentError.new("Scope '#{options[:as]}' already exists") if states_stores_options.keys.include?(options[:as])
        states_stores_options.each do |scope,conf_options|
          if conf_options[:in].to_sym == options[:in].to_sym
            raise ArgumentError.new("Scope '#{scope}' already store configuration in '#{conf_options[:in]}'")
          end
        end
      end

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
            humanized_array = [humanized_array] unless humanized_array.is_a?(Array)
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