module MAL
  module Parsers
  class History
  include Helpers

  def initialize(page, kind:)
    @page = page
    @kind = kind
  end

  def parse
    return [] if private?

    page.xpath("//tr[td[@class='borderClass']]").map { |row| parse_entry(row) }
  end

  private

  attr_reader :page, :kind, :timezone

  def private?
    page.at_xpath("//div[@class='badresult']").present?
  end

  def parse_entry(row)
    {
      timestamp: parse_natural_timestamp(clean_text(row.at_xpath(".//td[2]").text)),
      amount: row.at_xpath(".//td[1]/strong").text.to_i,
      item_id: extract_item_id(row),
      item_name: clean_text(row.at_xpath(".//td[1]/a").text),
      item_kind: kind.to_s
    }
  end

  def extract_item_id(row)
    row.at_xpath(".//td[1]/a/@href").value.partition("?id=").last.to_i
  end

  def parse_natural_timestamp(text)
    date = Chronic.parse(text, context: :past, now: Time.zone.now)

    # For non logged users, MAL uses pacific time as default timezone
    Time.find_zone("Pacific Time (US & Canada)").local(date.year, date.month, date.day, date.hour, date.min).utc
  end
  end
  end
end
