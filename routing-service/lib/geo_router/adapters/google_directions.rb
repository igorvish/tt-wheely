require 'faraday'
require 'oj'

module GeoRouter
  module Adapters

    #
    # Адаптер для Google Maps Directions API.
    # https://developers.google.com/maps/documentation/directions/start?hl=ru
    # Реализует функционал получения расстояния и времени для маршрута между
    # двумя точками.
    #
    class GoogleDirections < AbstractAdapter

      def initialize(settings)
        @settings = {
          key:         settings.fetch(:api_key, nil)
        }
      end

      def get(from, to, opts={})
        @connection ||= Faraday.new(url: 'http://maps.googleapis.com') do |i|
          i.request  :url_encoded
          i.response :logger
          i.adapter  Faraday.default_adapter
        end

        opts.merge!({
          origin:      Array(from).join(','),
          destination: Array(to).join(','),
          mode:        opts.fetch(:mode, 'driving'),
          key:         @settings[:key],
        }).compact

        resp = @connection.get('/maps/api/directions/json', opts)
        parse(resp.body)
      end

      private

      def parse(json_resp)
        ret = Oj.load(json_resp)
        
        {
          status:        ret.dig('status'),
          error_message: ret.dig('error_message'),
          distance_m:    ret.dig('routes', 0, 'legs', 0, 'distance', 'value'),
          duration_s:    ret.dig('routes', 0, 'legs', 0, 'duration', 'value'),
        }
      end

    end
  end
end
