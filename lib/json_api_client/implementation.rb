module JsonApiClient
  class Implementation
    attr_reader :version, :meta

    def initialize(data)
      # If the version member is not present, clients should assume the server implements at least version 1.0 of the specification.
      @version = data.fetch("version", "1.0")

      @meta = MetaData.new(data.fetch("meta", {}))
    end
  end
end