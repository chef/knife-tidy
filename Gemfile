source "https://rubygems.org"

gemspec

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
end

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

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

instance_eval(ENV["GEMFILE_MOD"]) if ENV["GEMFILE_MOD"]

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into Gemfile.local
eval_gemfile(__FILE__ + ".local") if File.exist?(__FILE__ + ".local")
