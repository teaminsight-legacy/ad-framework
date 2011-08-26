module Seed
  class << self

    def up
      self.down
      container = AD::Container.create({ :name => "AD Framework Tests" })
      users_container = AD::Container.create({
        :name => "Users", :treebase => "CN=AD Framework Tests"
      })
      user = AD::User.create({
        :name => "joe test", :system_flags => 1000, :sam_account_name => "jtest", 
        :object_sid => 1
      })
    end

    def down
      container = AD::Container.find("AD Framework Tests")
      dn = "CN=Users, CN=AD Framework Tests, #{AD::Container.treebase}"
      users_container = AD::Container.find(dn) if container
      user = AD::User.find("joe test") if users_container

      user.destroy if user
      users_container.destroy if users_container
      container.destroy if container
    end

  end
end
