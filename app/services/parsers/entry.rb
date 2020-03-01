module Parsers
  class Entry
    include CallableService

    attr_reader :kind, :page

    def initialize(kind, page)
      @kind = kind.to_s
      @page = page
    end

    def call
      {
        timestamp: extract_timestamp,
        amount: page.at_xpath(".//td[1]/strong").text.to_i,
        item_id: extract_item_id,
        item_name: page.at_xpath(".//td[1]/a/text()").text,
        item_kind: kind
      }
    end

    def extract_timestamp
      natural_timestamp = page.at_xpath(".//td[2]").text
      Chronic.parse(natural_timestamp, context: :past).change(sec: 0, usec: 0)
    end

    def extract_item_id
      page.at_xpath(".//td[1]/a/@href").value.partition("?id=").last.to_i
    end
  end
end
