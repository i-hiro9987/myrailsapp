FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid_#{n}" }
    provider { "github" }
    sequence(:name) { |n| "user#{n}" }
    image_url { "https://example.com/avatar.png" }
  end
end
