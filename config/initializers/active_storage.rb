# frozen_string_literal: true

module ActiveStorageJobAutoRetry
  extend ActiveSupport::Concern

  prepended do
    retry_on ActiveRecord::InvalidForeignKey, ActiveStorage::FileNotFoundError
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::TransformJob.prepend(ActiveStorageJobAutoRetry)
  ActiveStorage::AnalyzeJob.prepend(ActiveStorageJobAutoRetry)
end
