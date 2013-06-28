require 'faraday'
require 'typhoeus'

module Smugmug
  class Images
    def self.getInfo imageid, imagekey, options={}
      conn = Faraday.new(:url => 'http://api.smugmug.com') do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter :typhoeus 
      end

      response = conn.get do |req|
        req.url '/services/api/json/1.3.0/'
        req.params = { :method => "smugmug.images.getInfo",
          :ImageID => imageid, :ImageKey => imagekey }
      end
    end
  end
end
