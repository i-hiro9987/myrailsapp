FactoryBot.define do
  # ここは仮データ作成
  # sequenceは被りなしで
  factory :user do
    sequence(:uid) { |n| "uid_#{n}" }
    provider { "github" }
    sequence(:name) { |n| "user#{n}" }
    image_url { "https://example.com/avatar.png" }
  end
end
