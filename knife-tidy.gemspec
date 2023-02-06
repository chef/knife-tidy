$:.push File.expand_path("../lib", __FILE__)
require "knife-tidy/version"

Gem::Specification.new do |s|
  s.name             = "knife-tidy"
  s.version          = KnifeTidy::VERSION
  s.authors          = ["Chef Software, Inc."]
  s.email            = ["oss@chef.io"]
  s.summary          = "Report on stale Chef Infra Server nodes and cookbooks and clean up data integrity issues in a knife-ec-backup object based backup"
  s.description      = s.summary
  s.homepage         = "https://github.com/chef/knife-tidy"
  s.license          = "Apache-2.0"
  s.files            = %w{LICENSE} + Dir.glob("lib/**/*") + Dir.glob("conf/**/*")
  s.require_paths    = ["lib"]

  s.required_ruby_version = ">= 2.7.0"
end
