require "rollbar/deploy"

namespace :deployment do
  desc "Sends to the error tracking tool that the app has been deployed"
  task notify: :environment do
    Rails.logger.info Rollbar::Deploy.report(
                        { local_username: `whoami`.strip, repository: "andersonkrs/malheatmap", status: :succeeded },
                        Rails.application.credentials.rollbar[:token],
                        Rails.env.to_s,
                        ENV.fetch("KAMAL_VERSION")
                      )
  end
end
