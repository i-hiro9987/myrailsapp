FactoryBot.define do
  # ここは仮データ作成
  # associationは関連付けでfactoryで指定したモデルが作成されていることを前提？
  # -> Ans: 前提ではなく「自動で作成してくれる」が正確。build/createした際にFactoryBotが関連モデルも一緒に作成してくれる。
  # sequenceは指定したもの（名前など）が被らないようにしている？
  # -> Ans: 正解。|n|でテスト実行ごとに1,2,3...と増える連番が渡されるため一意な値を生成できる。
  # {}の前にからむ名を指定し、中に値を入れている
  factory :event do
    association :owner, factory: :user
    sequence(:name) { |n| "イベント#{n}" }
    place { "東京都渋谷区" }
    content { "イベントの内容です。" }
    start_at { 1.week.from_now }
    end_at { 1.week.from_now + 2.hours }
  end
end
