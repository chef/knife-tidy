$:.push File.expand_path("../lib", __FILE__)
require 'knife-tidy/version'

Gem::Specification.new do |s|
  s.name             = "knife-tidy"
  s.version          = KnifeTidy::VERSION
  s.version          = "#{s.version}-pre#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV["TRAVIS"]
  s.has_rdoc         = true
  s.authors          = ["Jeremy Miller"]
  s.email            = ["jmiller@chef.io"]
  s.summary          = "Report on stale Chef Server nodes and cookbooks and clean up data integrity issues in a knife-ec-backup object based backup"
  s.description      = s.summary
  s.homepage         = "https://github.com/chef-customers/knife-tidy"
  s.license          = "Apache License, v2.0"
  s.files            = `git ls-files`.split("\n")
  s.require_paths    = ["lib"]

  s.required_ruby_version = ">= 2.2.0"

  s.add_development_dependency "rake", "~> 11.0"
  s.add_development_dependency "rspec", "~> 3.4"
  s.add_development_dependency "aruba", "~> 0.6"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "simplecov-console", "~> 0.2"
  if ENV.key?("TRAVIS_BUILD") && RUBY_VERSION == "2.1.9"
    # Test version of Chef with Chef Zero before
    # /orgs/org/users/user/keys endpoint was added.
    s.add_development_dependency "chef", "12.8.1"
  else # Test most current version of Chef on 2.2.2
    s.add_development_dependency :chef
  end
end
