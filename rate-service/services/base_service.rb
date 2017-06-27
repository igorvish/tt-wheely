class BaseService

  class Error < RuntimeError; end

  def call(*args)
    raise NotImplementedError.new("You must implement call method")
  end

  #
  # Обертка для call(), но с выборосом исключения в случае ошибки.
  #
  def call!(*args)
    ret = self.call(*args)
    raise Error.new(ret.errors.join(' ')) if ret.failure?
    ret
  end

  private

    #
    # Методы для возврата результата в виде DTO.
    # При желании можно сделать конструкторами соответствующих классов.
    #
    # Example:
    #   ...
    #   return error(errors: ["Payment can't be created because fuck off"], invoice: @invoice)
    #   ...
    #
    def error(errors:, **key_args)
      opts = key_args.merge(status: :error, :success? => false, :failure? => true, errors: errors)
      # ::OpenStruct.new(opts) # No exeption on undefined method
      opts = opts.to_a.transpose # => [[keys], [values]]
      Struct.new( *opts[0] ).new( *opts[1] ) # Exeption on undefined method
    end

    def success(**key_args)
      opts = key_args.merge(status: :success, :success? => true, :failure? => false, errors: [])
      # ::OpenStruct.new(opts)
      opts = opts.to_a.transpose
      Struct.new( *opts[0] ).new( *opts[1] )
    end

end
