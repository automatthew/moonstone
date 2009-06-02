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
    
    # Reasonably useful basic examples
    
    # GET /search.html?input=happiness
    def html_GET_search(request)
      results = search(request.params['input'], search_options(request))
      results.join("\n<br>")
    end
    
    # GET /search.json?input=happiness
    def json_GET_search(request)
      results = search(request.params['input'], search_options(request))
      results.to_json
    end
    
    # POST /search.json
    def json_POST_search(request)
      options = search_options(request)
      data = request.env['rack.input'].read
      JSON.parse(data).map { |input| search(input, options) }.to_json
    end
    
  end
end