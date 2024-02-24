class CrawlingLogEntryVisitedPage < OpsRecord
  belongs_to :crawling_log_entry

  attribute :body, :compressed_text
end
