require_relative './abstract_calc.rb'

module Rate
  module Calcs

    #
    # Рассчитывает среднюю стоимость из вариантов "по времени"/"по расстоянию".
    #
    class AvgOfKiloAndDurationCalc < AbstractCalc

      def call(params)
        avg [calc_by_time(params), calc_by_kilo(params)]
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

        def avg(ary)
          ary.sum / ary.length
        end

        def ss
          @settings
        end

    end
  end
end
