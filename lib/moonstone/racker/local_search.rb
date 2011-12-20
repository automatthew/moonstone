require 'moonstone/racker'
module Moonstone
  module Racker
    module LocalSearch
      include Moonstone::Racker

      def json_GET_search(request)
        args = request.params.values_at('topic', 'lat', 'lon')
        options = search_options(request)
        args << options
        t = Time.now
        results = search(*args).to_hash
        results[:time] = Time.now - t
        results.to_json
      end

      # JSON body should contain an array of 3-element arrays (topic, lat, lon)
      #  curl -i -X POST -d '[ ["plumbers", "", ""], ["burgers", "", ""] ]' \
      #    http://localhost:9292/search.json
      def json_POST_search(request)
        options = search_options(request)
        data = request.env['rack.input'].read
        JSON.parse(data).map do |topic, lat, lon|
          t = Time.now
          results = search(input, lat, lon, options).to_hash
          results[:time] = Time.now - t
          results
        end.to_json
      end

    end
  end
end