require_relative './base_service.rb'

#
# Сервис-объект для рассчета тарифа по выбранному плану и указанному
# маршруту.
# Пример:
#
#   ```
#   RateService.new.call(
#     plan: :base, 
#     from: '34.1330949,-117.9143879', 
#     to: '33.8068768,-118.3527671'
#   )
#   # => ['base', 100500]
#   ```
#
class RateService < BaseService

  def call(params)
    # Проверяем валидность тарифного плана
    plan = params['plan']
    if plan.present? && !Rate.plans.include?(plan)
      return error(errors: ["Unknown tariff plan #{plan}.inspect"])
    end
    
    # Получаем дистанцию и расстояние маршрута
    resp = call_routing_microservice(params['from'], params['to'])
    return error(errors: resp[:errors]) if resp[:errors]

    # Считаем тариф для указанного плана (или для всех, если не указан)
    calcs = plan.present? ? Rate.calcs.slice(plan) : Rate.calcs
    ret = calcs.map do |plan, calc|
      [plan, calc.call(resp.slice(:distance_m, :duration_s))]
    end

    success(result: ret)
  end

  private

    #
    # Метод для вызова сервиса для получения инфо о маршруте.
    #
    def call_routing_microservice(from, to)
      @connection ||= Faraday.new(url: ENV.fetch('ROUTING_SVC_HOST', 'http://localhost:3001')) do |i|
        i.request  :url_encoded
        i.response :logger
        i.adapter  Faraday.default_adapter
      end

      resp = @connection.get('/route', from: from, to: to)
      Oj.load(resp.body).with_indifferent_access
    end

end
