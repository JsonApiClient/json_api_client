# Based on jsonapi_resources configuration.rb file

require 'json_api_client/formatter'

module JsonApiClient
  class Configuration
    attr_reader :json_key_format,
                :key_formatter,
                :route_format,
                :route_formatter

    def initialize
      #:underscored_key, :camelized_key, :dasherized_key, or custom
      self.json_key_format = :underscored_key

      #:underscored_route, :camelized_route, :dasherized_route, or custom
      self.route_format = :underscored_route
    end

    def json_key_format=(format)
      @json_key_format = format
      @key_formatter = JsonApiClient::Formatter.formatter_for(format)
    end

    def route_format=(format)
      @route_format = format
      @route_formatter = JsonApiClient::Formatter.formatter_for(format)
    end

  end

  class << self
    attr_accessor :configuration
  end

  @configuration ||= Configuration.new

  def self.configure
    yield(@configuration)
  end
end
