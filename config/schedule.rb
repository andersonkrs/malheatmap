# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end

every 15.minutes do
  runner "User::SchedulePeriodicMALSyncJob.perform_later"
end

every :day, at: "18:00pm" do
  rake "backups:perform"
end

every 2.hours do
  runner "SolidQueue::Job.clear_finished_in_batches"
end

# Learn more: http://github.com/javan/whenever
