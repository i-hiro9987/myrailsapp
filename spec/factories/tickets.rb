FactoryBot.define do
  factory :ticket do
    association :user
    association :event
    comment { "参加します！" }
  end
end
