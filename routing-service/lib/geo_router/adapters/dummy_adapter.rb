module GeoRouter
  module Adapters

    #
    # Адаптер-пустышка c расчетом расстояния по прямой.
    #
    class DummyAdapter < AbstractAdapter

      def initialize(settings)
      end

      def get(from, to, opts={})
        parse(HaversineFormula.distance_m(from, to))
      end

      private

      def parse(distance_m)
        {
          status:        'OK',
          error_message: nil,
          distance_m:    distance_m,
          duration_s:    distance_m / 8.33, # Время при скорости 30 км/ч (8.33 м/с)
        }
      end

    end
  end
end
