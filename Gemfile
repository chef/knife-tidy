source "https://rubygems.org"

gemspec

group :debug do
  gem "pry"
end

group :development do

  gem "contracts", "< 0.17" # .17 requires Ruby 3 and later. Remove this pin entirely when legacy Ruby support is dropped
  gem "chefstyle", "< 3.0" # 1.0 drops support for Ruby 2.3/2.4 format
  gem "rake"
  gem "rspec"

  # preserve testing on older ruby releases
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.5")
    gem "chef-zero", "< 14" # 14+ requires Ruby 2.4+
    gem "chef", "~> 13" # 14+ deps on mixlib-log 2+ which requires Ruby 2.4+
    gem "mixlib-shellout", "< 3.1" # 3.1 depends on chef-utils
    gem "activesupport", "~> 5.0" # 6+ requires Ruby 2.5+
    gem "cucumber", "~> 4.0" # 5+ requires Ruby 2.5+
    gem "aruba", "< 1.0" # 1+ requires Ruby 2.4+
    gem "parallel", "< 1.20" # 1.20+ requires Ruby 2.5+
    gem "mixlib-config", "< 3.0" # 3+ requires Ruby 2.4+
    gem "mixlib-archive", "< 1.0" # 1+ requires Ruby 2.4+
    gem "mixlib-cli", "< 2.0" # 2+ requires Ruby 2.4+
    gem "fakefs", "< 1.2" # 1.2+ requires Ruby 2.4+
  elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6")
    gem "chef-zero", "~> 14"
    gem "chef", "~> 15"
    gem "activesupport", "~> 6.0" # 7+ requires Ruby 2.7+
    gem "fakefs"
  elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7")
    gem "activesupport", "~> 6.0" # 7+ requires Ruby 2.7+
    gem "chef", "~> 15"
    gem "fakefs"
  elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.1")
    gem "chef-zero"
    gem "chef", "< 17" # 17 breaks out knife
    gem "aruba"
    gem "fakefs"
  else
    gem "chef-zero"
    gem "chef", "~> 18"
    gem "knife", "~> 18"
    gem "aruba"
    gem "fakefs"
  end
end