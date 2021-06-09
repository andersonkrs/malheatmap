namespace :users do
  desc "Merge the given users"
  task :merge, %i[old_username new_username] => [:environment] do |_task, args|
    old_user = User.find_by!(username: args[:old_username])
    new_user = User.find_by!(username: args[:new_username])

    new_user.merge!(old_user)
    new_user.crawl_data_later

    Rails.logger.info "Users have been merged successfully"
  end
end
