namespace :users do
  desc "Merge the given users"
  task :merge, %i[old_username new_username] => [:environment] do |_task, args|
    old_user = User.find_by(username: args[:old_username])

    if old_user.blank?
      Rails.logger.warn "Old user #{old_user} does not exist anymore or has been already merged"
      next
    end

    ApplicationRecord.transaction do
      new_user = User.create_or_find_by!(username: args[:new_username])

      old_user.entries.update_all(user_id: new_user.id)
      old_user.destroy

      new_user.update!(checksum: nil)
      new_user.crawl_mal_data_later
    end

    Rails.logger.info "Users have been merged succesfully"
  end
end
