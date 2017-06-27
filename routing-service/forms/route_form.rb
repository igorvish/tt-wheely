require 'forwardable'
require 'dry-validation'

#
# NB:
# Здесь вряд ли нужна такая усложненная валидация, она сделана
# для демонстрации подхода в общем случае.
#
# RouteForm.new(params).valid?
#
class RouteForm

  extend Forwardable

  #
  # Атрибуты формы
  #
  ATTRIBUTES = [:from, :to]
  attr_accessor *ATTRIBUTES

  #
  # Валидации
  #
  RouteSchema = Dry::Validation.Schema do
    configure do
      def self.messages
        super.merge(en: {errors: {lat_lon?: 'invalide coordinate value'}})
      end

      def lat_lon?(item)
        item.size == 2 &&
        (item[0] >= -90 && item[0] <= 90) && # latitude
        (item[1] >= -180 && item[1] <= 180) # longitude
      end
    end

    required(:from).filled{ lat_lon? }.each(:number?)
    required(:to).filled{ lat_lon? }.each(:number?)
  end

  #
  # Делегирование методов валидации к result-объекту
  #
  delegate [:errors, :messages, :success?, :failure?, :to_h] => :result
  def_delegator :result, :success?, :valid?

  #
  # Инициализация атрибутов из хеша параметров
  #
  def initialize(attrs)
    attrs = Hash[attrs.map{ |k, v| [k.to_sym, v] }]
    ATTRIBUTES.each{ |att| send("#{att}=", attrs[att]) }

    # Ожидаем строку или массив координат
    @from = @from.split(',').map(&:to_f) if @from.is_a?(String)
    @to   = @to.split(',').map(&:to_f)   if @to.is_a?(String)
  end

  #
  # Вызов валидации
  #
  def result
    @result ||= RouteSchema.call(
      Hash[ATTRIBUTES.map{ |key| [key, send(key)] }]
    )
  end

end
