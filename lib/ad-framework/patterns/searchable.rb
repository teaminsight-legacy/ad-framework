require 'ad-framework/utilities/entry_builder'

module AD
  module Framework
    module Patterns

      module Searchable
        class << self

          def included(klass)
            klass.class_eval do
              extend AD::Framework::Patterns::Searchable::ClassMethods
              include AD::Framework::Patterns::Searchable::InstanceMethods
            end
          end

        end

        module InstanceMethods

          # TODO: raise an error when cant find
          def reload
            # TODO: test that it will use fields distinguishedname or dn
            args = { 
              :where => { :dn__eq => (self.fields[:distinguishedname] || self.fields[:dn]) }, 
              :limit => 1 
            }
            search_args = self.class.build_ad_search_args(args)
            ldap_entry = self.connection.search(search_args).first
            AD::Framework::Utilities::EntryBuilder.new(ldap_entry, { :reload => self })
            self
          end

        end

        module ClassMethods

          # TODO: raise an error when cant find
          def find(dn)
            dn = self.build_ad_dn(dn)
            args = { :where => { :dn__eq => dn }, :size => 1 }
            self.fetch_ad_entry(args)
          end

          def first(args = {})
            args = { :where => args, :size => 1 }
            self.fetch_ad_entry(args)
          end

          def all(args = {})
            self.fetch_ad_entry(args, true)
          end

          def build_ad_search_args(args = {})
            default_args = {
              :objectclass__eq => self.schema.ldap_name,
              :base => self.schema.treebase
            }
            (args || {}).inject(default_args) do |search_args, (key, value)|
              case(key.to_sym)
              when :where
                if value.kind_of?(Array)
                  value = value.inject({}){|where, condition| where.merge(condition) }
                end
                search_args.merge(value)
              when :limit
                search_args.merge({ :size => value })
              else
                search_args.merge({ key => value })
              end
            end
          end

          protected

          def fetch_ad_entry(args, collection = false)
            search_args = self.build_ad_search_args(args)
            results = self.connection.search(search_args)
            if !collection
              ldap_entry = results.first
              AD::Framework::Utilities::EntryBuilder.new(ldap_entry).entry
            else
              results.collect do |ldap_entry|
                AD::Framework::Utilities::EntryBuilder.new(ldap_entry).entry
              end
            end
          end

          def build_ad_dn(dn)
            if dn !~ /DC=|CN=/
              [ "CN=#{dn}", self.treebase ].compact.join(", ")
            else
              dn
            end
          end

        end

      end

    end
  end
end
