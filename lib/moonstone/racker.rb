require 'rack'
require 'json'
module Moonstone
  module Racker
    
    PathMatcher = %r{^/([\w_]+)\.([\w_]+)$}
    
    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      if (m = method_name(request)) && (self.respond_to? m)
        response.body = self.send(m, request, response) || ""
      else
        response.status, response.body = 404, "404"
      end
      response.finish
    end
    
    def method_name(request)
      whole, action, ext = request.path_info.match(PathMatcher).to_a
      "#{ext || 'html'}_#{http_method(request)}_#{action}" if action
    end

    def http_method(request)
      rack_method = request.request_method.upcase
      if (rack_method == 'POST') && (fake = request.params['_method'])
        fake.upcase
      else
        rack_method
      end
    end
    
    def search_options(request)
      if limit = request.params['limit']
        {:limit => limit.to_i}
      end
    end
    
    # Reasonably useful basic methods
    
    def html_GET_search(request, response)
      args = [request.params['input'], search_options(request)].compact
      search(*args).join("\n<br>")
    end
    
    def json_GET_search(request, response)
      response['Content-Type'] = 'application/json'
      args = [request.params['input'], search_options(request)].compact
      search(*args).to_json
    end
    
    def json_POST_search(request, response)
      response['Content-Type'] = 'application/json'
      options = search_options(request)
      data = request.env['rack.input'].read
      JSON.parse(data).map { |input| search(input, options) }.to_json
    end
    
  end
end