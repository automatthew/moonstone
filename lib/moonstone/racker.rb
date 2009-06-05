require 'rack'
require 'json'
module Moonstone
  # include me in a Moonstone::Engine, maybe?
  module Racker
    
    PathMatcher = %r{^/([\w_]+)\.([\w_]+)$}
    
    def call(env)
      request, response = Rack::Request.new(env), Rack::Response.new
      # Determine (or possibly fake) an HTTP method
      real = request.request_method.upcase
      http_method = if (real == 'POST') && (fake = request.params['_method'])
        fake.upcase
      else
        real
      end
      # Match against a very limited species of URI path.
      whole, action, ext = request.path_info.match(PathMatcher).to_a
      # Poor man's content negotiation
      content_type = case ext
      when 'json'
        'application/json'
      end
      response['Content-Type'] = content_type if content_type
      # Poor man's routing
      method_name = action ? "#{ext || 'html'}_#{http_method}_#{action}" : nil
      if method_name && respond_to?(method_name)
        response.body = send(method_name, request).to_s
      else
        response.status, response.body = 404, "404"
      end
      response.finish
    end
    
    # helper for action methods
    def search_options(request)
      limit = request.params['limit']
      limit ? {:limit => limit.to_i} : {}
    end
    
    def json_GET_engine_version(request)
      { :name => self.class.name, 
        :version => `git show-ref -s --abbrev HEAD`.chomp
      }.to_json
    end
    
    def json_GET_index_version(request)
      { :build_date => index_metadata["build_date"],
          :engine_name => index_metadata["engine_name"],
          :engine_version => index_metadata["engine_version"],
          :query_conditions => index_metadata["query_conditions"]
      }.to_json
    end
    
    def self.generate_rackup(engine, store, *load_paths)
      here = File.expand_path(File.dirname(__FILE__))
      load_paths = load_paths.map { |p| "$:.unshift '#{p}'" }.join("\n")
      rackup = <<RACKUP
#{load_paths}
require 'lark'
require 'moonstone/racker/local_search'
#{engine}.module_eval do
  include Moonstone::Racker::LocalSearch
end
run #{engine}.new(:store => "#{store}")
RACKUP
    end
    
  end
end