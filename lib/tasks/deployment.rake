namespace :deployment do
  desc "Sends to the error tracking tool that the app has been deployed"
  task notify: :environment do
    app_json = JSON.parse(File.read(Rails.root.join("app.json")))

    Honeybadger.track_deployment(
      revision: ENV["GIT_REV"],
      local_username: `whoami`.strip,
      repository: app_json["repository"]
    )
  end
end
