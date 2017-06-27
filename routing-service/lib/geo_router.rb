module GeoRouter

  class Client

    def initialize(adapter, settings=nil)
      @client = GeoRouter::Adapters.const_get(adapter).new(settings || {})
    end

    def get(*params)
      @client.get(*params)
    end

  end

end
