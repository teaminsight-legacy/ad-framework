module AD
  module Framework

    class AttributeType

      class << self

        def inherited(klass)
          AD::Framework::AttributeType.inherited_attribute_types.push(klass)
        end

        def inherited_attribute_types
          @inherited_attribute_types ||= []
        end

        def key(new_value = nil)
          if new_value
            @key = new_value
          end
          @key
        end
        
        def define_attribute_type(attribute, klass)
          attribute_type_method = "#{attribute.name}_attribute_type"
          if !klass.instance_methods.collect(&:to_s).include?(attribute_type_method)
            klass.class_eval <<-DEFINE_ATTRIBUTE_TYPE

              def #{attribute_type_method}
                unless @#{attribute_type_method}
                  value = (self.fields["#{attribute.ldap_name}"] || []).first
                  type = #{attribute.attribute_type}.new(self, #{attribute.name}, value)
                  @#{attribute_type_method} = type
                end
                @#{attribute_type_method}
              end

            DEFINE_ATTRIBUTE_TYPE
          end
        end

        def define_reader(attribute, klass)
          self.define_attribute_type(attribute, klass)
          klass.class_eval <<-DEFINE_READER

            def #{attribute.name}
              self.#{attribute.name}_attribute_type.value
            end

          DEFINE_READER
        end

        def define_writer(attribute, klass)
          self.define_attribute_type(attribute, klass)
          klass.class_eval <<-DEFINE_WRITER

            def #{attribute.name}=(new_value)
              self.#{attribute.name}_attribute_type = new_value
              self.#{attribute.name}
            end

          DEFINE_WRITER
        end

      end

    end

  end
end
