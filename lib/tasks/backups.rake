namespace :backups do
  desc "Zips all the ActiveStorage files + Databases and push them to a file storage"
  task :perform do
    stamp = Time.current.to_fs(:number)
    backup_key = "backup_#{Rails.env}_#{stamp}.zip"
    backup_file = Rails.root.join("tmp/#{backup_key}")

    Rails.logger.info "Creating Backup under: #{backup_file}"

    ["storage/malheatmap_primary_#{Rails.env}.sqlite3"].each do |file|
      sql_file = Rails.root.join("tmp/#{File.basename(file.ext("#{stamp}.sql"))}")

      Rails.logger.info "Dumping database #{file} into #{sql_file}..."
      Rails.logger.info system "sqlite3 #{file} .dump > #{sql_file}"
      Rails.logger.info "Zipping database #{sql_file}..."
      Rails.logger.info system "zip -ur #{backup_file} #{sql_file}"

      Rails.logger.info "Cleaning up #{sql_file}..."
      FileUtils.rm_f sql_file
    end
    Rails.logger.info "Zipping databases complete!"

    Rails.logger.info "Zipping ActiveStorage files..."
    Rails.logger.info system "zip -ur #{backup_file} storage/#{Rails.env}"
    Rails.logger.info "Zipping ActiveStorage files complete!"

    env = {
      "AWS_ACCESS_KEY_ID" => Rails.configuration.backups.aws_access_key_id,
      "AWS_SECRET_ACCESS_KEY" => Rails.configuration.backups.aws_secret_access_key
    }
    bucket_name = Rails.configuration.backups.aws_bucket

    "Uploading to S3...."
    Rails.logger.info system(env, "aws s3 cp #{backup_file} s3://#{bucket_name}/#{backup_key}")

    Rails.logger.info "Cleaning up #{backup_file}..."
    FileUtils.rm_f backup_file.to_s

    Rails.logger.info "Backup complete!"
  end
end
