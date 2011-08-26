require 'assert'

module AD::Framework::Patterns::Searchable

  class BaseTest < Assert::Context
    desc "AD::Framework::Searchable"
    setup do
      @class = Class.new(AD::Framework::StructuralClass) do
        include AD::Framework::Patterns::Searchable
        ldap_name "randomClass"
        treebase "OU=Random"
      end
      AD::Framework.register_structural_class(@class)
      @fields = { "objectclass" => [ @class.schema.ldap_name ] }
      instance_fields = @fields.dup.merge({ "dn" => "CN=something, DC=example, DC=com" })
      @instance = @class.new(:fields => instance_fields)
    end
    subject{ @instance }

    should have_instance_methods :reload
    should have_class_methods :find, :first, :all

    should "search for it's ldap entry and reset it's fields a call to #reload" do
      expected = { :dn__eq => subject.fields[:dn], :size => 1,
        :objectclass__eq => subject.schema.ldap_name, :base => subject.schema.treebase }
      self.mock_connection(expected, [ @fields ])

      assert_nothing_raised{ subject.reload }
      assert_equal(@fields, subject.fields)
    end

    should "search for it's entry with its distinguishedname then dn with a call to #reload" do
      subject.fields[:distinguishedname] = "distinguishedname test"
      subject.fields[:dn] = "dn test"
      expected = { :dn__eq => subject.fields[:distinguishedname], :size => 1,
        :objectclass__eq => subject.schema.ldap_name, :base => subject.schema.treebase }
      self.mock_connection(expected, [ @fields ])

      assert_nothing_raised{ subject.reload }
      subject.fields[:distinguishedname] = nil
      expected[:dn__eq] = subject.fields[:dn]
      self.mock_connection(expected, [ @fields ])

      assert_nothing_raised{ subject.reload }
    end

    should "raise a not found exception if it's dn is bad with a call to #reload" do
      subject.fields[:distinguishedname] = subject.fields[:dn] = nil
      expected = { :dn__eq => subject.fields[:dn], :size => 1,
        :objectclass__eq => subject.schema.ldap_name, :base => subject.schema.treebase }
      self.mock_connection(expected, [])

      assert_raises(AD::Framework::EntryNotFound){ subject.reload }
    end

    should "search with the args passed and return a single entry with a call to #first" do
      args = { :name => "someone" }
      expected = { :name => args[:name], :size => 1, :objectclass__eq => @class.schema.ldap_name,
        :base => @class.schema.treebase }
      self.mock_connection(expected, [ @fields ])

      found = nil
      assert_nothing_raised{ found = @class.first(args) }
      assert found
      assert_equal(@fields, found.fields)
    end

    should "search with the args passed and return multiple entries with a call to #all" do
      args = { :where => { :name => "*some*" } }
      expected = { :name => args[:where][:name], :objectclass__eq => @class.schema.ldap_name,
        :base => @class.schema.treebase }
      self.mock_connection(expected, [ @fields.dup, @fields.dup ])

      all = nil
      assert_nothing_raised{ all = @class.all(args) }
      assert_instance_of Array, all
      all.each{|found| assert_equal(@fields, found.fields) }
    end

    should "return an entry with a matching dn with a call to #find" do
      dn = "CN=someone, #{@class.schema.treebase}"
      expected = { :dn__eq => dn, :size => 1, :objectclass__eq => @class.schema.ldap_name,
        :base => @class.schema.treebase }
      self.mock_connection(expected, [ @fields ])

      found = nil
      assert_nothing_raised{ found = @class.find(dn) }
      assert found
      assert_equal(@fields, found.fields)
    end

    should "return an entry with a matching rdn with a call to #find" do
      rdn = "someone"
      expected = { :dn__eq => "CN=#{rdn}, #{@class.schema.treebase}", :size => 1,
        :objectclass__eq => @class.schema.ldap_name, :base => @class.schema.treebase }
      self.mock_connection(expected, [ @fields ])

      found = nil
      assert_nothing_raised{ found = @class.find(rdn) }
      assert found
      assert_equal(@fields, found.fields)
    end

    should "raise an error when no entry is found with a call to #find" do
      dn = "CN=someone, #{@class.schema.treebase}"
      expected = { :dn__eq => dn, :size => 1, :objectclass__eq => @class.schema.ldap_name,
        :base => @class.schema.treebase }
      self.mock_connection(expected, [])

      assert_raises(AD::Framework::EntryNotFound){ @class.find(dn) }
    end

    teardown do
      AD::Framework.defined_object_classes.delete(@class.ldap_name.to_sym)
    end

    def mock_connection(expected, results)
      mock_connection = mock()
      @class.expects(:connection).returns(mock_connection)
      mock_connection.expects(:search).with(expected).returns(results)
    end
  end

end
