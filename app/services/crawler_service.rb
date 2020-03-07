require "mechanize"

class CrawlerService < Mechanize
  include CallableService
  include ApplicationHelper

  def initialize(username)
    super()
    @username = username
    @result = { status: :success }

    setup_agent_options
  end

  def call
    fetch_data
    result
  end

  private

  attr_reader :result, :username

  def setup_agent_options
    self.history_added = proc { sleep Rails.application.config.crawler_requests_interval }
    self.open_timeout = 25.seconds
    self.read_timeout = open_timeout
  end

  def fetch_data
    fetch_profile
    fetch_entries
  rescue Mechanize::ResponseCodeError => error
    handle_response_code_error(error)
  end

  def fetch_profile
    get mal_profile_url(username)
    parse_profile
  end

  def parse_profile
    result[:profile] = Parsers::Profile.call(page)
  end

  def fetch_entries
    result[:entries] = []
    page.link_with(text: "History").click

    parse_entries(:anime)
    parse_entries(:manga)
  end

  def parse_entries(kind)
    page.link_with(text: "#{kind.capitalize} History").click

    page.xpath("//tr[td[@class='borderClass']]").each do |row|
      result[:entries] << Parsers::Entry.call(kind, row)
    end
  end

  def handle_response_code_error(error)
    custom_error_messages = {
      "404" => "Profile not found for username #{username}. Please check if you typed it correctly."
    }

    result[:status] = :error
    result[:message] = custom_error_messages[error.response_code] || error.message
  end
end
