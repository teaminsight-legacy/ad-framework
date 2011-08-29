require 'assert'

module AD::Framework::Patterns::Searchable

  class BaseTest < Assert::Context
    desc "AD::Framework::Searchable"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "searchableTestObject"
        treebase "OU=Random"
      end
      AD::Framework.register_structural_class(@structural_class)
      @fields = { "objectclass" => [ @structural_class.schema.ldap_name ] }
      instance_fields = @fields.dup.merge({ "dn" => "CN=something, DC=example, DC=com" })
      @instance = @structural_class.new({ :fields => instance_fields })
    end
    subject{ @instance }

    should have_instance_methods :reload
    should have_class_methods :find, :first, :all

    teardown do
      AD::Framework.defined_object_classes.delete(@structural_class.ldap_name.to_sym)
    end
  end

  class ReloadTest < BaseTest
    desc "reload method"
    setup do
      @search_args = {
        :objectclass__eq => @instance.class.ldap_name, :base => @instance.treebase, :size => 1
      }
      @distinguishedname = "distinguishedname test"
      @dn = "dn test"
      @instance.fields[:distinguishedname] = @distinguishedname
      @instance.fields[:dn] = @dn
      @mock_connection = mock()
      @instance.expects(:connection).returns(@mock_connection)
    end
  end

  class WithDistinguishedNameTest < ReloadTest
    desc "with distinguishedname field set"
    setup do
      @search_args[:dn__eq] = @instance.fields[:distinguishedname]
      @mock_connection.expects(:search).with(@search_args).returns([ @fields ])
    end

    should "call search on it's connection with the distinguishedname field" do
      assert_nothing_raised{ subject.reload }
    end
  end

  class WithDnTest < ReloadTest
    desc "without distinguishedname and with dn field set"
    setup do
      @instance.fields[:distinguishedname] = nil
      @search_args[:dn__eq] = @instance.fields[:dn]
      @mock_connection.expects(:search).with(@search_args).returns([ @fields ])
    end

    should "call search on it's connection with the dn field" do
      assert_nothing_raised{ subject.reload }
    end
  end

  class WithInvalidDnTest < ReloadTest
    desc "with an invalid dn"
    setup do
      @instance.fields[:distinguishedname] = @instance.fields[:dn] = nil
      @search_args[:dn__eq] = nil
      @mock_connection.expects(:search).with(@search_args).returns([])
    end
    should "raise a not found exception if the search returns no entries" do
      assert_raises(AD::Framework::EntryNotFound){ subject.reload }
    end
  end

  class FirstMethodTest < BaseTest
    desc "first method"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "firstSearchableTestObject"
      end
      @first_args = { :name => "someone" }
      @search_args = {
        :name => @first_args[:name], :objectclass__eq => @structural_class.ldap_name,
        :base => @structural_class.treebase, :size => 1
      }
      @mock_connection = mock()
      @structural_class.expects(:connection).returns(@mock_connection)
      @mock_connection.expects(:search).with(@search_args).returns([ @fields ])
    end
    subject{ @structural_class }

    should "search with the args passed and return a single entry" do
      found = nil
      assert_nothing_raised{ found = subject.first(@first_args) }
      assert found
      assert_equal @fields, found.fields
    end
  end

  class AllMethodTest < BaseTest
    desc "all method"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "allSearchableTestObject"
      end
      @all_args = { :where => { :name => "*some*" } }
      @search_args = {
        :name => @all_args[:where][:name], :objectclass__eq => @structural_class.ldap_name,
        :base => @structural_class.treebase
      }
      @mock_connection = mock()
      @structural_class.expects(:connection).returns(@mock_connection)
      @mock_connection.expects(:search).with(@search_args).returns([ @fields.dup, @fields.dup ])
    end
    subject{ @structural_class }

    should "search with the args passed and return multiple entries" do
      all = nil
      assert_nothing_raised{ all = subject.all(@all_args) }
      assert_instance_of Array, all
      all.each{|found| assert_equal(@fields, found.fields) }
    end
  end

  class FindMethodWithDnTest < BaseTest
    desc "find method with a dn"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "findWithDNSearchableTestObject"
      end
      @dn = "CN=someone, #{@structural_class.treebase}"
      @search_args = {
        :dn__eq => @dn, :objectclass__eq => @structural_class.ldap_name,
        :base => @structural_class.treebase, :size => 1
      }
      @mock_connection = mock()
      @structural_class.expects(:connection).returns(@mock_connection)
      @mock_connection.expects(:search).with(@search_args).returns([ @fields ])
    end
    subject{ @structural_class }

    should "return an entry with a matching dn" do
      found = nil
      assert_nothing_raised{ found = subject.find(@dn) }
      assert found
      assert_equal(@fields, found.fields)
    end
  end

  class FindMethodWithRdnTest < BaseTest
    desc "find method with a rdn"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "findWithRDNSearchableTestObject"
      end
      @rdn = "someone"
      @search_args = {
        :dn__eq => "CN=#{@rdn}, #{@structural_class.treebase}", :base => @structural_class.treebase,
        :objectclass__eq => @structural_class.ldap_name, :size => 1
      }
      @mock_connection = mock()
      @structural_class.expects(:connection).returns(@mock_connection)
      @mock_connection.expects(:search).with(@search_args).returns([ @fields ])
    end
    subject{ @structural_class }

    should "return an entry with a matching rdn" do
      found = nil
      assert_nothing_raised{ found = subject.find(@rdn) }
      assert found
      assert_equal(@fields, found.fields)
    end
  end

  class FindMethodWithNotResultTest < BaseTest
    desc "find method that returns no result"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "findWithDNSearchableTestObject"
      end
      @dn = "CN=someone, #{@structural_class.treebase}"
      @search_args = {
        :dn__eq => @dn, :objectclass__eq => @structural_class.ldap_name,
        :base => @structural_class.treebase, :size => 1
      }
      @mock_connection = mock()
      @structural_class.expects(:connection).returns(@mock_connection)
      @mock_connection.expects(:search).with(@search_args).returns([])
    end
    subject{ @structural_class }

    should "raise an error when no entry is found" do
      assert_raises(AD::Framework::EntryNotFound){ subject.find(@dn) }
    end
  end

end
