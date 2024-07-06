class Backup < ApplicationRecord
  attribute :key, :string, default: -> { "backup_#{Rails.env}_#{Time.current.to_fs(:number)}" }

  has_one_attached :file, service: :cloud_backups

  include Executable
end
