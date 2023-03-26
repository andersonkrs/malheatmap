class ApplicationClient < HttpClient
  logger Rails.logger.tagged(name)
end
