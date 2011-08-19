require 'ad-framework/patterns/has_schema'

module AD
  module Framework

    module AuxiliaryClass      
      class << self
        
        def included(klass)
          klass.class_eval do
            include AD::Framework::Patterns::HasSchema
            
            def self.included(klass)
              super
              klass.schema.add_auxiliary_class(self)
            end
          end
        end
        
      end
    end

  end
end
