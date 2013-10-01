module JsonApiClient
  class Parser

    def self.parse(klass, response)
      data = JSON.parse(response.body)
      Array(data.fetch(klass.table_name, [])).map do |attrs|
        klass.new(attrs)
      end
    end

  end
end