module MAL
  module Parsers
    class History
      def initialize(page, kind:)
        @page = page
        @kind = kind
      end

      def parse
        return [] if private?

        @page.xpath("//tr[td[@class='borderClass']]").map do |row|
          parse_entry(row)
        end
      end

      private

      def private?
        @page.at_xpath("//div[@class='badresult']").present?
      end

      def parse_entry(row)
        {
          timestamp: row.at_xpath(".//td[2]").text.strip,
          amount: row.at_xpath(".//td[1]/strong").text.to_i,
          item_id: extract_item_id(row),
          item_name: row.at_xpath(".//td[1]/a").text,
          item_kind: @kind.to_s
        }
      end

      def extract_item_id(row)
        row.at_xpath(".//td[1]/a/@href").value.partition("?id=").last.to_i
      end
    end
  end
end
