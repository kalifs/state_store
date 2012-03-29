require 'state_store/binary_store'
require 'state_store/extension'

module StateStore
  def self.included(base_klass)
    base_klass.extend(StateStore::Extension::ClassMethods)
    base_klass.class_eval do 
      include StateStore::Extension::InstanceMethods
    end
  end
end