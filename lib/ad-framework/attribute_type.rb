module AD
  module Framework

    class AttributeType
      attr_accessor :object, :attr_ldap_name, :value, :ldap_value

      def initialize(object, attr_ldap_name, value = nil)
        self.object = object
        self.attr_ldap_name = attr_ldap_name
        self.value = (value || self.value_from_field)
      end

      def value_from_field
        (self.object.fields[self.attr_ldap_name] || []).first
      end

      def value=(new_value)
        @value = new_value
        self.ldap_value = @value
        @value
      end

      def ldap_value=(new_ldap_value)
        self.object.fields[self.attr_ldap_name] = if new_ldap_value
          [*new_ldap_value].collect(&:to_s)
        else
          []
        end
        @ldap_value = new_ldap_value
      end
      
      def reset
        self.value = self.value_from_field
      end

      def inspect
        attr_display = [ :value, :ldap_value, :attr_ldap_name ].collect do |attr|
          "#{attr}: #{self.instance_variable_get("@#{attr}").inspect}"
        end
        attr_display.push("object: #{object.class} - #{object.dn.inspect}")
        [ "#<#{self.class} ", attr_display.sort.join(", "), ">" ].join
      end

      class << self

        def key(new_value = nil)
          if new_value
            @key = new_value
          end
          @key
        end

        def define_attribute_type(attribute, klass)
          method_name = "#{attribute.name}_attribute_type"
          if !klass.instance_methods.collect(&:to_s).include?(method_name)
            attribute_type_method = self.attribute_type_method(attribute, method_name)
            if attribute_type_method.kind_of?(::Proc)
              klass.class_eval(&attribute_type_method)
            else
              klass.class_eval(attribute_type_method.to_s)
            end
          end
        end

        def attribute_type_method(attribute, method_name)
          <<-DEFINE_ATTRIBUTE_TYPE

            def #{method_name}
              unless @#{method_name}
                type = #{attribute.attribute_type}.new(self, "#{attribute.ldap_name}")
                @#{method_name} = type
              end
              @#{method_name}
            end

          DEFINE_ATTRIBUTE_TYPE
        end

        def define_reader(attribute, klass)
          self.define_attribute_type(attribute, klass)
          reader_method = self.reader_method(attribute)
          if reader_method.kind_of?(::Proc)
            klass.class_eval(&reader_method)
          else
            klass.class_eval(reader_method.to_s)
          end
        end

        def reader_method(attribute)
          <<-DEFINE_READER

            def #{attribute.name}
              self.#{attribute.name}_attribute_type.value
            end

          DEFINE_READER
        end

        def define_writer(attribute, klass)
          self.define_attribute_type(attribute, klass)
          writer_method = self.writer_method(attribute)
          if writer_method.kind_of?(::Proc)
            klass.class_eval(&writer_method)
          else
            klass.class_eval(writer_method.to_s)
          end
        end

        def writer_method(attribute)
          <<-DEFINE_WRITER

            def #{attribute.name}=(new_value)
              self.#{attribute.name}_attribute_type.value = new_value
              if self.respond_to?("#{attribute.name}")
                self.#{attribute.name}
              else
                new_value
              end
            end

          DEFINE_WRITER
        end

      end

    end

  end
end
