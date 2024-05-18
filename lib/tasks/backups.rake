namespace :backups do
  desc "Zips all the ActiveStorage files + Databases and push them to a file storage"
  task perform: :environment do
    Backup.execute!
  end
end
