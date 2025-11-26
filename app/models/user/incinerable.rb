class User
  module Incinerable
    extend ActiveSupport::Concern

    def enqueue_incineration
      User::Incinerable::IncinerationJob.perform_later(self)
    end

    def incinerate!
      User::Incineration.new(self).perform
    end

    class IncinerationJob < ApplicationJob
      queue_as :within_20_hours

      def perform(user)
        user.incinerate!
        Rails.logger.info "User #{user.username} incinerated"
      end
    end
  end
end
