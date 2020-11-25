FactoryBot.define do
  factory :subscription do
    username { Faker::Internet.unique.username(separators: %w[_-]) }
    processed { false }
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

  factory :activity do
    association :user
    association :item

    date { Faker::Date.in_date_period }
    amount { Faker::Number.positive.to_i }

    trait :anime do
      association :item, kind: :anime
    end

    trait :manga do
      association :item, kind: :manga
    end
  end

  factory :item do
    mal_id { Faker::Number.unique.positive.to_i }
    name { Faker::Book.title }
    kind { Item.kinds.keys.sample }

    initialize_with do
      Item.find_or_initialize_by(**attributes.slice(:mal_id, :kind)) do |item|
        item.name = attributes[:name]
      end
    end
  end
end
