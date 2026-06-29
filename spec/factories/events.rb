FactoryBot.define do
  factory :event do
    association :owner, factory: :user
    sequence(:name) { |n| "イベント#{n}" }
    place { "東京都渋谷区" }
    content { "イベントの内容です。" }
    start_at { 1.week.from_now }
    end_at { 1.week.from_now + 2.hours }
  end
end
