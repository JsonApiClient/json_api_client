module JsonApiClient
  class Parser

    def self.parse(klass, data)
      Array(data.fetch(klass.table_name, [])).map do |attrs|
        klass.new(attrs)
      end
    end

  end
end