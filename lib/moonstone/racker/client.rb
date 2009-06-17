module Moonstone
  module Racker
    module LocalClient
      
      def search(topic, location, options={})
        raise "Unable to use supplied location: #{location}" unless loc = geo(location)
        query = {:input => topic, :lat => loc['latitude'].to_s, :lon => loc['longitude'].to_s}
        r = HTTParty.get("#{uri}/search.json", :query => query)
        hash = {}
        r.each { |k,v| hash[k] = v }
        hash['location'] = loc
        hash
      rescue Errno::ECONNREFUSED
        {}
      end
      
      def geo(location)
        lat = location['lat'] || location['latitude'] || location['LAT'] || 
          location[:lat] || location[:latitude]
        lon = location['lon'] || location['long'] || location['LON'] ||
          location['longitude'] || location[:lon] || 
          location[:long] || location[:longitude]
        {'latitude' => lat, "longitude" => lon} if lat && lon
      end

      def index_info
        HTTParty.get("#{uri}/index_info.json")
      rescue Errno::ECONNREFUSED
        {}
      end

      def details(id)
        HTTParty.get("#{uri}/document.json", :query => {:id => id})
      rescue Errno::ECONNREFUSED
        {}
      end
    end
  end
end