FactoryBot.define do
  # ここは仮データ作成
  # associationは関連付けでfactoryで指定したモデルが作成されていることを前提？
  # -> Ans: events.rbと同様。前提ではなく自動作成。:userや:eventのfactoryが定義されていれば名前省略も可能。
  factory :ticket do
    association :user
    association :event
    comment { "参加します！" }
  end
end
