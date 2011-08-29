require 'ad-framework/utilities/transaction'

module AD
  module Framework
    module Patterns

      module Callbacks
        class << self

          def included(klass)
            klass.class_eval do
              include AD::Framework::Patterns::Callbacks::InstanceMethods
            end
          end

        end
        
        module InstanceMethods
          
          def create
            transaction = AD::Framework::Utilities::Transaction.new(:create, self) do
              super
            end
            transaction.run
          end
          
          def update
            transaction = AD::Framework::Utilities::Transaction.new(:update, self) do
              super
            end
            transaction.run
          end
          
          def destroy
            transaction = AD::Framework::Utilities::Transaction.new(:destroy, self) do
              super
            end
            transaction.run
          end
          
        end
        
      end

    end
  end
end
