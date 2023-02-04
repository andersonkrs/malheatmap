require "net/http"
require "uri"

namespace :deployment do
  desc "Sends to the error tracking tool that the app has been deployed"
  task notify: :environment do
    app_json = JSON.parse(Rails.root.join("app.json").read)

    result =
      Net::HTTP.post URI("https://api.rollbar.com/api/1/deploy"),
                     {
                       environment: Rails.env.to_s,
                       revision: ENV.fetch("GIT_REV"),
                       local_username: `whoami`.strip,
                       repository: app_json["repository"]
                     }.to_json,
                     "Content-Type" => "application/json",
                     "X-Rollbar-Access-Token" => Rails.application.credentials.rollbar[:token]

    pp result.body
  end
end
