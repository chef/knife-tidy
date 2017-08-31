require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require 'chef/knife/tidy_base'
require 'chef/knife'
require 'chef/config'
require 'stringio'

class Tester < Chef::Knife
  include Chef::Knife::TidyBase
end

describe Chef::Knife::TidyBase do
  let(:t) { Tester.new }
  before(:each) do
    @rest = double('rest')
    @stderr = StringIO.new
    allow(t.ui).to receive(:stderr).and_return(@stderr)
    allow(Chef::ServerAPI).to receive(:new).and_return(@rest)
  end

  context "completion_message" do
    it "lets the user know we're Finished" do
      expect{t.completion_message}.to output("** Finished **\n").to_stdout
    end
  end
end
