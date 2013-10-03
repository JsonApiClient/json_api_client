module JsonApiClient
  class Parser

    def self.parse(klass, response)
      ResultSet.build(klass, response.body)
    end

  end
end