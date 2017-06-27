module Rate
  module Calcs
    class AbstractCalc

      REQUIRED_SETTINGS = [
        :pickup_cost,
        :per_minute,
        :per_km,
        :min_cost,
      ]

      REQUIRED_ARGS = [
        :distance_m,
        :duration_s,
      ]

      def initialize(params)
        # ... validate
        @settings = params
      end

      def call(params)
        raise NotImplementedError.new("You must implement call method")
      end

    end
  end
end
