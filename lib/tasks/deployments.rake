namespace :deployment do
  desc "Sends to the error tracking tool that the app has been deployed"
  task notify: :environment do
    # TODO: Implement solid errors deployment tracking
  end
end
