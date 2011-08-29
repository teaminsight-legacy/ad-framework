module AD
  module Framework
    module Utilities

      class Transaction
        attr_accessor :callbacks, :entry, :block
        
        def initialize(action, entry, &block)
          self.entry = entry
          self.callbacks = (self.entry.schema.callbacks[action.to_sym] || {})
          self.block = block
        end
        
        def run
          self.run_callbacks(self.callbacks[:before])
          self.entry.instance_eval(&self.block)
          self.run_callbacks(self.callbacks[:after])
        end
        
        protected
        
        def run_callbacks(methods)
          (methods || []).each do |method|
            self.entry.send(method)
          end
        end
        
      end

    end
  end
end
