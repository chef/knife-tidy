source "https://rubygems.org"

gemspec

if vsn = ENV['TRAVIS_CHEF_VERSION']
  if m = /branch:(?<branch>.*)$/.match(vsn)
    gem 'chef', git: 'https://github.com/chef/chef', branch: m[:branch]
  else
    gem 'chef', vsn
  end
end

group :development do
  gem 'rspec'
  gem 'rake'
  gem 'simplecov'
  gem 'fakefs'
  gem "chefstyle", git: "https://github.com/chef/chefstyle.git"
  gem "chef-zero"
end

group :changelog do
  gem "github_changelog_generator", git: "https://github.com/chef/github-changelog-generator"
end

# This is here instead of gemspec so that we can
# override which Chef gem to use when we do testing
# Possibilities in the future include using environmental
# variables, thus allowing us to to have Travis support

# Examples you can use in Gemfile.local
# gem 'chef', '~> 10.28'
# gem 'chef' # latest
# gem 'chef', git: 'git://github.com/mal/chef.git', branch: 'CHEF-3307'

# If you want to load debugging tools into the bundle exec sandbox,
# # add these additional dependencies into Gemfile.local
eval(IO.read(__FILE__ + '.local'), binding) if File.exists?(__FILE__ + '.local')
