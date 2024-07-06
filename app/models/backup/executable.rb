class Backup
  module Executable
    extend ActiveSupport::Concern

    class_methods do
      def take_now!
        create!(started_at: Time.current).tap do |backup|
          backup.execute!
        end
      end
    end

    def execute!
      if finished_at.present?
        self.failure_message = "Backup already finished at: #{finished_at}"
        return
      end

      backup_files!
      self.finished_at = Time.current
    rescue StandardError => e
      self.failure_message ||= e.message
    ensure
      save!

      Rails.logger.error(failure_message) if failure_message.present?
    end

    private

    def backup_files!
      tmp_zip = Dir::Tmpname.create(["#{key}_", ".tar.gz"]) { }

      Rails.logger.info "Creating Backup under: #{tmp_zip}"

      Tempfile.open(["primary_", "sqlite3.sql"]) do |sql_file|
        Rails.logger.info "Dumping database into #{sql_file.path}..."
        system("sqlite3 #{primary_db_path} .dump > #{sql_file.path}", exception: true)

        Rails.logger.info "Zipping files ..."
        system("tar -czvf #{tmp_zip} #{sql_file.path} storage/#{Rails.env}", exception: true)
        Rails.logger.info "Storage zipped!"
      end

      attach(tmp_zip)
      Rails.logger.info "Backup complete!"
    ensure
      FileUtils.rm(tmp_zip)
      Rails.logger.info("#{tmp_zip} removed")
    end

    private

    def attach(tmp_zip)
      Rails.logger.info "Attaching backup file..."
      file.attach(
        io: File.open(tmp_zip),
        filename: key,
        content_type: "application/x-tgz",
        key: key,
      )
    end

    def primary_db_path
      Rails.application.config.database_configuration[Rails.env]["primary"]["database"]
    end
  end
end
