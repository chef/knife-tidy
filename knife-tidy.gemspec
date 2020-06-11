$:.push File.expand_path("../lib", __FILE__)
require "knife-tidy/version"

Gem::Specification.new do |s|
  s.name             = "knife-tidy"
  s.version          = KnifeTidy::VERSION
  s.version          = "#{s.version}-pre#{ENV["TRAVIS_BUILD_NUMBER"]}" if ENV["TRAVIS"]
  s.authors          = ["Jeremy Miller"]
  s.email            = ["jmiller@chef.io"]
  s.summary          = "Report on stale Chef Server nodes and cookbooks and clean up data integrity issues in a knife-ec-backup object based backup"
  s.description      = s.summary
  s.homepage         = "https://github.com/chef-customers/knife-tidy"
  s.license          = "Apache-2.0"
  s.files            = %w{LICENSE} + Dir.glob("lib/**/*") + Dir.glob("conf/**/*")
  s.require_paths    = ["lib"]

  s.required_ruby_version = ">= 2.3.0"
end
