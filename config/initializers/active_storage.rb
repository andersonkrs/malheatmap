# frozen_string_literal: true

module TransformJobExtension
  extend ActiveSupport::Concern

  prepended do
    discard_on ActiveRecord::InvalidForeignKey, ActiveStorage::FileNotFoundError
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::TransformJob.prepend(TransformJobExtension)
end
