require 'moonstone/racker'
module Moonstone
  module Racker
    module BasicSearch
      include Moonstone::Racker
      
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
end