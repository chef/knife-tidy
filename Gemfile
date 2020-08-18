source "https://rubygems.org"

gemspec

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer", "0.4.12" # remove this pin when we drop support for Ruby < 2.6
end

group :development do
  gem "aruba"
  gem "chefstyle"
  gem "fakefs"
  gem "rake"
  gem "rspec"
  gem "simplecov"
  gem "simplecov-console"

  # preserve testing on older ruby releases
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.5")
    gem "chef-zero", "~> 14"
    gem "chef", "~> 14"
    gem "activesupport", "~> 5.0"
  elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6")
    gem "chef-zero", "~> 14"
    gem "chef", "~> 15"
  else
    gem "chef-zero"
    gem "chef"
  end
end

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end
