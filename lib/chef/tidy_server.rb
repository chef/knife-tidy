class Chef
  class TidyServer
    attr_accessor :root_url

    def initialize(root_url)
      @root_url = root_url
    end

    def self.from_chef_server_url(url)
      url = url.gsub(/\/organizations\/+[^\/]+\/*$/, '')
      Chef::Server.new(url)
    end
  end
end
