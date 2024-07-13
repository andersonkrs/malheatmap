class Backup < ApplicationRecord
  attribute :key, :string, default: -> {
    app_name =  Rails.application.class.module_parent_name.underscore
    "backup_#{app_name}_#{Rails.env}_#{Time.zone.today.to_fs(:number)}"
  }

  has_one_attached :file, service: :cloud_backups

  include Executable

  def to_s
    "Backup:#{key}"
  end
end
