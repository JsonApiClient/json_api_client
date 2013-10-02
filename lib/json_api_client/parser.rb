module JsonApiClient
  class Parser

    def self.parse(klass, response)
      data = response.body
      ResultSet.build(klass, data)
    end

  end
end