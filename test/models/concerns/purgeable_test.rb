require "test_helper"

class PurgeableTest < ActiveSupport::TestCase
  class Bucket < ApplicationRecord
    include Purgeable

    purge_after 10.days
  end

  setup do
    ActiveRecord::Base
      .connection
      .create_table(:buckets) do |t|
        t.column :label, :string
        t.timestamps
      end

    @record = Bucket.new(label: "mine")
  end

  test "record needs to be purged after it's been created" do
    assert_enqueued_with job: Purgeable::PurgeRecordJob, args: [@record] do
      @record.save!
    end

    perform_enqueued_jobs
    assert_equal true, Bucket.exists?(id: @record.id)

    travel_to 9.days.from_now

    perform_enqueued_jobs
    assert_equal true, Bucket.exists?(id: @record.id)

    travel_to 10.days.from_now

    perform_enqueued_jobs
    assert_equal false, Bucket.exists?(id: @record.id)
  end
end
