module AD
  module Framework
    module Utilities

      class Validator
        attr_accessor :entry

        def initialize(entry)
          self.entry = entry
        end

        def errors
          self.entry.schema.mandatory.inject({}) do |errors, attribute_name|
            attribute_type = self.entry.send("#{attribute_name}_attribute_type")
            if !attribute_type.is_set?
              errors[attribute_name.to_s] = "was not set"
            end
            errors
          end
        end

      end

    end
  end
end
