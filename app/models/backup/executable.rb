
class Backup
  module Executable
    extend ActiveSupport::Concern

    class_methods do
      def execute!
        backup = create!(started_at: Time.current)
        begin
          backup.execute!
        rescue StandardError => e
          Rails.logger.error(e)
          backup.failure_message = e.message
        ensure
          backup.finished_at = Time.current
          backup.save!
          backup.cleanup!
        end
      end
    end

    def execute!
      Rails.logger.info "Creating Backup under: #{temp_zip_file}"
      Rails.logger.info "Zipping databases ..."

      ["storage/malheatmap_primary_#{Rails.env}.sqlite3"].each do |database_file|
        Tempfile.open([File.basename(database_file), ".sql"]) do |sql_file|
          dump_database(database_file, sql_file)

          Rails.logger.info "Zipping database #{sql_file.path}..."

          zip_database_dump(sql_file)
        end
      end

      Rails.logger.info "Zipping databases complete!"

      zip_active_storage_files

      Rails.logger.info "Uploading zip file..."
      upload!
      Rails.logger.info "Backup complete!"
    end

    def cleanup!
      FileUtils.rm_f(temp_zip_file)
    end

    private

    def temp_zip_file
      @temp_zip_file ||= Rails.root.join("tmp", "#{key}.zip")
    end

    def dump_database(database_file, sql_file)
      Rails.logger.info "Dumping database #{database_file} into #{sql_file.path}..."
      stdout, status = Open3.capture2("sqlite3 #{database_file} .dump > #{sql_file.path}")

      unless status.success?
        Rails.logger.error(stdout)
        raise "Failed to dump database #{database_file}!"
      end
    end

    def zip_database_dump(sql_file)
      stdout, status = Open3.capture2("zip -ur #{temp_zip_file} #{sql_file.path}")
      unless status.success?
        Rails.logger.error(stdout)
        raise "Failed to zip database #{sql_file.path}!"
      end
    end

    def zip_active_storage_files
      Rails.logger.info "Zipping ActiveStorage files..."
      stdout, status = Open3.capture2("zip -ur #{temp_zip_file} storage/#{Rails.env}")
      unless status.success?
        Rails.logger.error(stdout)
        raise "Failed to zip ActiveStorage files!"
      end
    end

    def upload!
      file.attach(
        io: File.open(temp_zip_file),
        filename: File.basename(temp_zip_file),
        content_type: "application/zip",
        key: File.basename(temp_zip_file),
      )
    end
  end
end
