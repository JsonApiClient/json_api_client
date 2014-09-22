module JsonApiClient
  module Query
    class FindEach < Base
      self.request_method = :get

      def call(&block)
        each_page do |results|
          results.each(&block)
        end
      end

      private

      def each_page(&block)
        page = 1
        while page
          results = klass.page(page).where(params).to_a
          block.call(results)
          page = results.next_page
        end
      end
    end
  end
end
