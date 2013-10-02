class ResultSet < Array

  attr_accessor :total_pages, :total_entries, :offset, :per_page, :current_page

  def self.build(klass, data)
    records = Array(data.fetch(klass.table_name, [])).map do |attributes|
      klass.new(attributes)
    end

    meta = data.fetch("meta", {})
    new(records).tap do |array|
      array.per_page = meta.fetch("per_page") do
        array.length
      end
      array.total_entries = meta.fetch("total_entries") do
        array.length
      end
      array.current_page = meta.fetch("current_page", 1)

      # can fall back to calculating via total entries and per_page
      array.total_pages = meta.fetch("total_pages") do
        (1.0 * array.total_entries / array.per_page).ceil
      end

      # can fall back to calculating via per_page and current_page
      array.offset = meta.fetch("offset") do
        array.per_page * (array.current_page - 1)
      end
    end
  end

end