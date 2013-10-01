module JsonApiClient
  class Connection
    attr_reader :faraday

    def initialize(site, &block)
      @faraday = Faraday.new(site, &block)
    end

    def execute(query)
      response = query.execute(faraday)
      json = JSON.parse(response.body)
      Array(json).map{|data| query.klass.new(data) }
    end

  end
end