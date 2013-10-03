module JsonApiClient
  module Links
    extend ActiveSupport::Concern

    included do
      attr_accessor :links

      initialize do |obj, params|
        links = params.delete(:links)
        obj.links = links if links
      end
    end
  end
end