require_relative './base_service.rb'
require 'geohash'

class RoutingService < BaseService

  extend Dry::Configurable
  setting :cache

  # Geohash     Level   Dimensions
  # g             1   ~ 5,004km x 5,004km
  # gc            2   ~ 1,251km x 625km
  # gcp           3   ~ 156km x 156km
  # gcpu          4   ~ 39km x 19.5km
  # gcpuu         5   ~ 4.9km x 4.9km
  # gcpuuz        6   ~ 1.2km x 0.61km
  # gcpuuz9       7   ~ 152.8m x 152.8m
  # gcpuuz94      8   ~ 38.2m x 19.1m
  # gcpuuz94k     9   ~ 4.78m x 4.78m
  # gcpuuz94kk    10   ~ 1.19m x 0.60m
  # gcpuuz94kkp   11   ~ 14.9cm x 14.9cm
  # gcpuuz94kkp5  12   ~ 3.7cm x 1.8cm  
  CACHE_PRECISION = 7

  def initialize(params)
    @form = RouteForm.new(params)

    @adapters = [
      :GoogleDirections,
      :DummyAdapter
    ]
  end

  def call
    # Выполняем валидацию
    return error(errors: @form.errors) unless @form.valid?

    coords = @form.from, @form.to

    # Обращаемся к провайдеру для рассчета маршрута. 
    # Фоллбек к очередному провайдеру в случае неудачи.
    # Кешируем ответ.
    ret = cache.fetch(cache_key_for(*coords), expires_in: 1.minute) do
      @adapters.each do |adapter|
        ret = GeoRouter::Client.new(adapter).get(*coords)
        break ret if ret[:status] == 'OK'
      end
    end

    ret[:status] == 'OK' ? success(result: ret) : error(errors: ["Route not found"], result: ret)
  end

  private

    #
    # Геттер кеш-движка из конфига класса (см. initializers).
    #
    def cache
      self.class.config.cache
    end

    #
    # Формирование ключа для кеша при помощи геохеша с указанным уровнем точности.
    #
    def cache_key_for(from, to, precision=CACHE_PRECISION)
      from = GeoHash.encode(*from, precision)
      to = GeoHash.encode(*to, precision)
      "#{from}:#{to}"
    end

end
