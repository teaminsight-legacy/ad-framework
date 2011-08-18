module AD
  module Framework
    class Config

      class Mapping < Hash
      
        def [](lookup)
          super(lookup.to_sym)
        end
        def find(lookup)
          self[lookup]
        end
      
        def []=(lookup, object)
          super(lookup.to_sym, object)
        end

        def add(lookup, object)
          self[lookup] = object
        end

      end

    end
  end
end
