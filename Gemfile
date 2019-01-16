source "https://rubygems.org"

gemspec

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
end

group :development do
  gem "aruba"
  gem "chef"
  gem "chef-zero"
  gem "chefstyle", git: "https://github.com/chef/chefstyle.git"
  gem "fakefs"
  gem "rake"
  gem "rspec"
  gem "simplecov"
  gem "simplecov-console"
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
