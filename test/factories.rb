require "faker"

FactoryBot.define do
  factory :subscription do
    username { Faker::Internet.unique.username(separators: %w[_-]) }
    status { :pending }
  end

  factory :user do
    username { Faker::Internet.unique.username(separators: %w[_-]) }
    avatar_url { Faker::Avatar.image }
    checksum { SecureRandom.hex }
  end

  factory :entry do
    association :user
    timestamp { Time.zone.now }
    amount { Faker::Number.positive.to_i }
    item_id { Faker::Number.positive.to_i }
    item_name { Faker::Book.title }
    item_kind { Entry.item_kinds.keys.sample }
  end
end
