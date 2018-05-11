require 'faraday'
require 'faraday_middleware'

module Flockd
  module Query
    class Basic
      def initialize(type)
        @type = type
      end

      def retrieve(endpoint, params = {})
        retrieve!(endpoint, params)
      rescue Faraday::ConnectionFailed
        '-'
      end

      def retrieve!(endpoint, params = {})
        resp = connection(endpoint).get("query/#{@type}", params)
        resp.body['report']
      end

      private
      def connection(endpoint)
        Faraday.new(endpoint) do |conn|
          conn.response :json, :content_type => /\bjson$/
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
