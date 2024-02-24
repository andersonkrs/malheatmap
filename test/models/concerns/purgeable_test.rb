require "test_helper"

class PurgeableTest < ActiveSupport::TestCase
  class Bucket < ApplicationRecord
    include Purgeable

    purge after: 10.days
  end

  setup do
    ActiveRecord::Base
      .connection
      .create_table(:buckets) do |t|
        t.column :label, :string
        t.column :purge_after, :datetime

        t.timestamps
      end
  end

  test "record needs to be purged after it's been created" do
    record = Bucket.new(label: "mine")
    assert_in_delta 10.days.from_now, record.purge_after, 5
    record.save!

    Bucket.purge_due
    assert_equal true, Bucket.exists?(id: record.id)

    travel_to 9.days.from_now

    Bucket.purge_due
    assert_equal true, Bucket.exists?(id: record.id)

    travel_to 10.days.from_now

    Bucket.purge_due
    assert_equal false, Bucket.exists?(id: record.id)
  end

  test "purge after and method can be overridden" do
    record = Bucket.new(label: "mine", purge_after: 2.days.from_now)

    assert_in_delta 2.days.from_now, record.purge_after, 5

    record.save!

    Bucket.purge_due
    assert_equal true, Bucket.exists?(id: record.id)

    travel_to 3.days.from_now

    Bucket.purge_due
    assert_equal false, Bucket.exists?(id: record.id)
  end

  test "automatically purge when creating stuff" do
    record_a = Bucket.create!(label: "mine", purge_after: 2.days.from_now)

    travel_to 15.days.from_now

    record_b = Bucket.create!(label: "other", purge_after: 2.days.from_now)

    assert_enqueued_with job: Purgeable::PurgeDueLaterJob, args: [PurgeableTest::Bucket]

    perform_enqueued_jobs only: Purgeable::PurgeDueLaterJob

    assert_equal false, Bucket.exists?(id: record_a.id)
    assert_equal true, Bucket.exists?(id: record_b.id)
  end
end
