module StateStore
  module Extension

    module ClassMethods
      def has_statuses *statuses
        @state_store_options = statuses && statuses.last.is_a?(Hash) && statuses.pop || {}
        raise ArgumentError.new("No statuses given") if statuses.empty? 
        raise ArgumentError.new(":in is required") unless @state_store_options[:in]
        @store = StateStore::BinaryStore.new(statuses)
        override_method_store_in_method
      end 

      def state_store_store
        @store
      end

      def state_store_options
        @state_store_options
      end

      private

      def override_method_store_in_method
        class_eval  <<-ALIAS,__FILE__,__LINE__+1  
          if self.instance_methods.include?(:#{self.state_store_options[:in]})
            alias :status_store_original_#{self.state_store_options[:in]} :#{self.state_store_options[:in]}
          end
        ALIAS

        self.class_eval do 
          define_method self.state_store_options[:in] do 
            original_method_name = :"status_store_original_#{self.class.state_store_options[:in]}"
            value = self.respond_to?(original_method_name) ? self.send(original_method_name) : super
            self.class.state_store_store.humanize(value)
          end
        end
      end
    end

    module InstanceMethods
      def self.included(base)

        def method_missing(method_name, *args)
          if method_name.to_s == "has_#{self.class.state_store_options[:in]}?"
            self.class.state_store_store.has_status?(args[0],self.send(self.class.state_store_options[:in]))
          else
            super
          end
        end 
      end
    end
  end
end