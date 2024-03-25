namespace :backups do
  desc "Zips all the ActiveStorage files + Databases and push them to a file storage"
  task :perform do
    backup_key = "backup_#{Rails.env}_#{Time.current.to_fs(:number)}.zip"
    backup_file = Rails.root.join("tmp/#{backup_key}")
    at_exit { FileUtils.rm_f backup_file.to_s }

    puts "Creating Backup under: #{backup_file}"

    puts "Zipping storage files..."
    FileList["storage/#{Rails.env}/**/*"].each do |file|
      puts system "zip -ur #{backup_file} #{file}"
    end
    puts "Zipping storage files complete!"

    # Exclude logging database
    FileList["storage/*#{Rails.env}.sqlite3"].exclude(/malheatmap_ops/).each do |file|
      puts "Dumping database #{file}"
      puts system "sqlite3 #{file} .dump > #{file.ext("sql")}"
      puts "Zipping database #{file.ext("sql")}..."
      puts system "zip -ur #{backup_file} #{file.ext("sql")}.sql"
    end
    puts "Zipping databases complete!"

    env = {
      "AWS_ACCESS_KEY_ID" => Rails.configuration.backups.aws_access_key_id,
      "AWS_SECRET_ACCESS_KEY" => Rails.configuration.backups.aws_secret_access_key
    }
    bucket_name = Rails.configuration.backups.aws_bucket

    "Uploading to S3...."
    puts system(env, "aws s3 cp #{backup_file} s3://#{bucket_name}/#{backup_key}")

    puts "Backup complete!"
  end
end
