require "zip"

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
        end
      end
    end

    def execute!
      Tempfile.open(["backup_#{Rails.env}_", ".zip"], binmode: true) do |tmp_zip|
        self.key = File.basename(tmp_zip.path)

        Rails.logger.info "Creating Backup under: #{tmp_zip.path}"

        ::Zip::File.open(tmp_zip.path, create: false) do |zip|
          Tempfile.open(["primary_", "sqlite3.sql"]) do |sql_file|
            dump_database("storage/malheatmap_primary_#{Rails.env}.sqlite3", sql_file)
            Rails.logger.info "Zipping database #{sql_file.path}..."

            zip.add(File.basename(sql_file), sql_file.path)
            zip.commit
            Rails.logger.info "Database zipped!"
          end

          Rails.logger.info "Zipping storage files ..."

          directory = Rails.root.join("storage/#{Rails.env}")
          Dir[File.join("storage/#{Rails.env}", "**", "**")].each do |file|
            Rails.logger.info "Adding #{file} to zip..."
            zip.add(file, file)
          end
          zip.commit
          Rails.logger.info "Storage files zipped!"
        end

        attach(tmp_zip)

        Rails.logger.info "Backup complete!"
      end
    end

    private

    def dump_database(database_file, sql_file)
      Rails.logger.info "Dumping database #{database_file} into #{sql_file.path}..."
      stdout, status = Open3.capture2("sqlite3 #{database_file} .dump > #{sql_file.path}")

      unless status.success?
        Rails.logger.error(stdout)
        raise "Failed to dump database #{database_file}!"
      end
    end

    def attach(tmp_zip)
      Rails.logger.info "Attaching zip file..."
      file.attach(
        io: File.open(tmp_zip.path),
        filename: key,
        content_type: "application/zip",
        key: key,
      )
    end
  end
end
