class Backup
  module Executable
    extend ActiveSupport::Concern

    class_methods do
      def take_now!
        create!(started_at: Time.current).tap do |backup|
          Rails.logger.tagged(backup.to_s) do
            backup.execute!
          end
        end
      end
    end

    def to_s
      "Backup:#{key}"
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

      Tempfile.open([File.basename(primary_db_name, ".sqlite3"), ".sqlite3"]) do |dump_file|
        Rails.logger.info "Dumping database into #{dump_file.path}..."
        dest = SQLite3::Database.new(dump_file)
        backup = SQLite3::Backup.new(dest, "main", ApplicationRecord.connection.raw_connection, "main")
        backup.step(-1)
        backup.finish
        dest.close
        Rails.logger.info "Database dump completed!"

        Rails.logger.info "Zipping files ..."
        system("tar -czvf #{tmp_zip} #{dump_file.path} storage/#{Rails.env}", exception: true)
        Rails.logger.info "Files zipped!"
      end

      attach(tmp_zip)
      Rails.logger.info "Backup completed!"
    ensure
      FileUtils.rm(tmp_zip)
      Rails.logger.info("#{tmp_zip} removed")
    end

    private

    def attach(tmp_zip)
      Rails.logger.info "Attaching backup file..."
      file.attach(
        io: File.open(tmp_zip),
        filename: File.basename(tmp_zip),
        content_type: "application/x-tgz",
        key: File.basename(tmp_zip),
      )
    end

    def primary_db_name
      File.basename(primary_db_path)
    end

    def primary_db_path
      Rails.application.config.database_configuration[Rails.env]["primary"]["database"]
    end
  end
end
