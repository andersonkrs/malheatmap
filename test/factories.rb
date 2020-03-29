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
    association :item

    timestamp { Time.zone.now }
    amount { Faker::Number.positive.to_i }

    trait :anime do
      association :item, kind: :anime
    end

    trait :manga do
      association :item, kind: :manga
    end
  end

  factory :item do
    mal_id { Faker::Number.positive.to_i }
    name { Faker::Book.title }
    kind { Item.kinds.keys.sample }
  end
end
