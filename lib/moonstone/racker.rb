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
      params = request.params
      limit = params['limit']
      offset = params['offset']
      options = {}
      options[:limit] = limit.to_i if limit
      options[:offset] = offset.to_i if offset
      options
    end
    
    def json_GET_engine_version(request)
      { :name => self.class.name, 
        :version => `git show-ref -h -s --abbrev HEAD`.chomp.split.first
      }.to_json
    end
    
    def json_GET_index_info(request)
      md = index_metadata || {}
      {   :build_date => md["build_date"],
          :build_engine => {  :name => md["engine_name"], 
                              :version => md["engine_version"]},
          :query_conditions => md["query_conditions"],
          :doc_count => doc_count
      }.to_json
    end
    
    def json_GET_document(request)
      document(request.params['id'].to_i).to_json
    end
    
    def self.generate_rackup_file(engine, store)      
      rackup = <<RACKUP
options[:Port] = 9293
#{yield}
require 'moonstone/racker/local_search'
#{engine}.module_eval do
  include Moonstone::Racker::LocalSearch
end
run #{engine}.new(:store => "#{File.expand_path store}")
RACKUP

      File.open "#{File.dirname(store)}/config.ru", "w" do |f|
        f.puts rackup
      end
    end
    
  end
end