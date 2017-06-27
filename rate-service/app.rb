require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
require 'yaml'
require 'oj'
require 'faraday'
%w[lib services].each do |dir|
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
  # Получение стоимости по тарифу: /rate?from=lat,lon&to=lat,lon&plan=name
  # E.g.: /rate?from=34.1330949,-117.9143879&to33.8068768,-118.3527671&plan=base
  #
  get '/rate' do
    ret = RateService.new.call(params)

    if ret.success?
      [200, Oj.dump(ret.result, mode: :compat)]
    else
      [422, Oj.dump({errors: ret.errors}, mode: :compat)]
    end
  end

end
