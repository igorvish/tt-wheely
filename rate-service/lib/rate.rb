#
# Модуль-контейнер для калькуляторов.
# Пример использования:
#
#   ```
#   classic_rate = Rate.calcs[:classic].call(params)
#
#   # OR
#
#   all_rates = Rate.calcs.map do |plan, calc|
#     [plan, calc.call(params)]
#   end
#   ```
#
module Rate

  #
  # Хеш объектов-калькуляторов в виде `plan_name => calc_instance`.
  #
  @plan_calcs = {}.with_indifferent_access

  #
  # Инициализация/обновление калькуляторов для тарифных планов.
  #
  def self.update(plans)
    updates_count = 0

    plans.with_indifferent_access.each do |name, params|
      next unless Rate::Calcs.const_defined?(params[:calculator].classify)

      @plan_calcs[name] = Rate::Calcs.const_get(params[:calculator].classify)
        .new(params.except(:calculator))
      updates_count += 1
    end

    updates_count
  end

  #
  # Список кальк-объектов
  #
  def self.calcs
    @plan_calcs
  end

  #
  # Список загруженных тарифов
  #
  def self.plans
    @plan_calcs.keys
  end

end
