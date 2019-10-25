require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require "chef/tidy_common"

describe Chef::TidyCommon do
  let(:t) { Chef::TidyCommon.new("/tmp/") }

  context "#cookbook_name_from_path" do
    it "correctly parses the cookbook name from a path" do
      expect(t.cookbook_name_from_path("/data/chef_backup/snapshots/20191008040001/organizations/myorg/cookbooks/chef-sugar-5.0.4")).to eq("chef-sugar")
    end
  end

  context "#cookbook_version_from_path" do
    it "correctly parses the cookbook version from a path even if org is also named cookbooks" do
      expect(t.cookbook_version_from_path("/data/chef_backup/snapshots/20191008040001/organizations/cookbooks/cookbooks/chef-sugar-5.0.4")).to eq("5.0.4")
    end

    it "correctly parses the cookbook version from a path even if its within the cookbook" do
      expect(t.cookbook_version_from_path("/data/chef_backup/snapshots/20191008040001/organizations/cookbooks/cookbooks/chef-sugar-5.0.4/files/foo.bar")).to eq("5.0.4")
    end

    it "correctly parses the cookbook version from a path even if its within the cookbook and is within a cookbooks dir" do
      expect(t.cookbook_version_from_path("/data/chef_backup/snapshots/20191008040001/organizations/cookbooks/cookbooks/chef-sugar-5.0.4/files/cookbooks/foo.bar")).to eq("5.0.4")
    end
  end
end
