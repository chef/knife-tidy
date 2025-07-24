source "https://rubygems.org"

gemspec

group :debug do
  gem "pry"
end

group :development do
  gem "chefstyle", "< 3.0"  # 3.0 drops support for older Ruby
  gem "rake"
  gem "rspec"

  # Ruby >= 2.7 support
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.1")
    gem "contracts", "< 0.17" # .17 requires Ruby 3 and later. Remove this pin entirely when legacy Ruby support is dropped
    gem "chef-zero"
    gem "chef", "< 17" # 17 breaks out knife
    gem "aruba"
    gem "fakefs"
  else
    gem "net-smtp"
    gem "syslog"
    gem "contracts", "~> 0.17.2"
    gem "chef-zero"
    gem "chef", "~> 18"
    gem "knife", "~> 18"
    gem "aruba"
    gem "fakefs"
  end
end
