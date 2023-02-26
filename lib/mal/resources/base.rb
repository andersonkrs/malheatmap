# frozen_string_literal: true
#
module MAL
  module Resources
    class Base < ActiveResource::Base
      self.site = MAL::URLS.base_api_url
      self.logger = Rails.logger
      self.include_format_in_path = false
    end
  end
end
