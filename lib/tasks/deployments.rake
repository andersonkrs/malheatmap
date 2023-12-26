require "net/http"
require "uri"
require "rollbar/deploy"

namespace :deployment do
  desc "Sends to the error tracking tool that the app has been deployed"
  task notify: :environment do
    app_json = JSON.parse(Rails.root.join("app.json").read)

    Rails.logger.info Rollbar::Deploy.report(
                        { local_username: `whoami`.strip, repository: app_json["repository"], status: :succeeded },
                        Rails.application.credentials.rollbar[:token],
                        Rails.env.to_s,
                        ENV.fetch("GIT_REV")
                      )
  end
end
