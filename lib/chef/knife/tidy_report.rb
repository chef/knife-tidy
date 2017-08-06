require 'chef'
require 'json'
require 'optparse'
require 'uri'

def output_list(list)
  list.each do |name, versions|
    #puts "#{name}: #{versions}"
  end
end

def get_cookbook_list(endpoint)
  cb_list = {}
  cookbooks = endpoint.get_rest('/cookbooks?num_versions=all')
  cookbooks.each do |name, data|
    data['versions'].each do |version_hash|
      version = Gem::Version.new(version_hash['version']).to_s
      if cb_list[name] && !cb_list[name].include?(version)
        cb_list[name].push(version)
      else
        cb_list[name] = [version]
      end
    end
  end
  cb_list
end

def get_cookbook_count(cb_list)
  cb_count_list = {}
  cb_list.each do |name, versions|
    cb_count_list[name] = versions.count
  end
  cb_count_list
end

def get_unused_cookbooks(used_list, cb_list)
  unused_list = {}
  cb_list.each do |name, versions|
    if used_list[name].nil? # Not in the used list at all (Remove all versions)
      unused_list[name] = versions
    elsif used_list[name].sort != versions  # Is in the used cookbook list, but version arrays do not match (Find unused versions)
      unused_list[name] = versions - used_list[name]
    end
  end
  unused_list
end

def get_all_orgs(server_root)
  chef_endpoint = Chef::ServerAPI.new("#{server_root}")
  orgs = chef_endpoint.get_rest('organizations')
  org_list = []
  orgs.each do |name, url|
    org_list << name
  end
  org_list
end

options = {}
OptionParser.new do |opt|
  opt.on('--orgs ORG1,ORG2') { |o| options[:org_list] = o }
  opt.on('--all-orgs') { |o| options[:all_orgs] = o }
  opt.on('--node-threshold NUM_DAYS') { |o| options[:threshold_days] = o }
  opt.on('--knife-config PATH_TO_KNIFE_RB') { |o| options[:knife_config] = o }
end.parse!

knife_config = options[:knife_config] || "#{ENV['HOME']}/.chef/knife.rb"

Chef::Config.from_file(knife_config)
chef_server_root = URI.join(Chef::Config['chef_server_url'], "/").to_s
orgs =  if options[:all_orgs]
          get_all_orgs(chef_server_root)
        elsif options[:org_list]
          options[:org_list].split(',')
        else
          ['myorg']
        end
threshold_in_days = options[:threshold_days] || 30

stale_orgs = []
orgs.each do |org|
  chef_endpoint = Chef::ServerAPI.new("#{chef_server_root}/organizations/#{org}")
  puts "Processing organization #{org}..."
  cb_list = get_cookbook_list(chef_endpoint)
  version_count = get_cookbook_count(cb_list).sort_by(&:last).reverse.to_h
  output_list(version_count)
  nodes = Chef::Search::Query.new("#{chef_server_root}/organizations/#{org}").search(:node, '*:*', :filter_result => {'name' => ['name'], 'cookbooks' => ['cookbooks'], 'ohai_time' => ['ohai_time']} )
  used_cookbooks = {}
  #nodes[0].select{|node| node.class == Array}.each do |node|
  nodes[0].select{|node| !node['cookbooks'].nil?}.each do |node|
    node['cookbooks'].each do |name, version_hash|
      version = Gem::Version.new(version_hash['version']).to_s
      if used_cookbooks[name] && !used_cookbooks[name].include?(version)
        used_cookbooks[name].push(version)
      else
        used_cookbooks[name] = [version]
      end
    end
  end
  threshold_in_days = 30
  stale_nodes = []
  nodes[0].each do |n|
    if (Time.now.to_i - n['ohai_time'].to_i) >= threshold_in_days * 86400
      stale_nodes.push(n['name'])
    end
  end
  stale_nodes_hash = {'threshold_days': threshold_in_days, 'count': stale_nodes.count, 'list': stale_nodes}
  stale_orgs.push(org) if stale_nodes.count == nodes[0].count
  Dir.mkdir('output') unless File.directory?('output')
  File.write("output/#{org}_unused_cookbooks.json", JSON.pretty_generate(get_unused_cookbooks(used_cookbooks, cb_list)))
  File.write("output/#{org}_cookbook_count.json", JSON.pretty_generate(version_count))
  File.write("output/#{org}_#{threshold_in_days}d_stale_nodes.json", JSON.pretty_generate(stale_nodes_hash))
end
