require 'rubygems'
require 'bundler/setup'
require 'sinatra'
%w(forms lib services).each do |dir|
  Dir[File.join(File.dirname(__FILE__), dir, '**/*.rb')].each { |file| require file }
end
Dir[File.join(File.dirname(__FILE__), 'initializers', '**/*.rb')].each { |file| require file }

class App < Sinatra::Base

  #
  # Healthcheck-роут
  #
  get '/healthcheck' do
    200
  end

  #
  # Получение данных о маршруте: /route?from=lat,lon&to=lat,lon
  # E.g.: /route?from=34.1330949,-117.9143879&to33.8068768,-118.3527671
  #
  get '/route' do
    ret = RoutingService.new(params).call

    if ret.success?
      [200, Oj.dump(ret.result, mode: :compat)]
    else
      [422, Oj.dump({errors: ret.errors}, mode: :compat)]
    end
  end

end
