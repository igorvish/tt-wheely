require_relative './abstract_calc.rb'

module Rate
  module Calcs

    #
    # Считает максимальный из вариантов "по времени"/"по расстоянию".
    # Если тариф не подразумевает стоимость одного из вариантов (например, per_minute = 0),
    # тогда считает только оставшийся.
    #
    class PlainCalc < AbstractCalc

      def call(params)
        by_time = ss[:per_minute] > 0 ? calc_by_time(params) : 0
        by_kilo = ss[:per_km] > 0 ? calc_by_kilo(params) : 0

        [by_time, by_kilo].max
      end

      private

        def calc_by_time(params)
          [
            (ss[:pickup_cost] + ss[:per_minute] * (params[:duration_s].to_f / 60.0).ceil),
            ss[:min_cost]
          ].max.round
        end

        def calc_by_kilo(params)
          [
            (ss[:pickup_cost] + ss[:per_km] * (params[:distance_m].to_f / 1000.0).ceil),
            ss[:min_cost]
          ].max.round
        end

        def ss
          @settings
        end

    end
  end
end
