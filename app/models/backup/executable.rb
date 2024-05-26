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
      tmp_zip = Dir::Tmpname.create(["#{key}_", ".zip"]) { }

      Rails.logger.info "Creating Backup under: #{tmp_zip}"

      Tempfile.open(["primary_", "sqlite3.sql"]) do |sql_file|
        Rails.logger.info "Dumping database into #{sql_file.path}..."
        system("sqlite3 storage/malheatmap_primary_#{Rails.env}.sqlite3 .dump > #{sql_file.path}", exception: true)

        Rails.logger.info "Zipping database #{sql_file.path}..."
        system("zip #{tmp_zip} #{sql_file.path}", exception: true)

        Rails.logger.info "Database zipped!"
      end

      Rails.logger.info "Zipping storage files ..."
      system("zip -r #{tmp_zip} storage/#{Rails.env}/", exception: true)

      Rails.logger.info "Storage files zipped!"
    ensure
      attach(tmp_zip)
      Rails.logger.info "Backup complete!"
      FileUtils.rm(tmp_zip)
    end

    private

    def attach(tmp_zip)
      Rails.logger.info "Attaching zip file..."
      file.attach(
        io: File.open(tmp_zip),
        filename: key,
        content_type: "application/zip",
        key: key,
      )
    end
  end
end
