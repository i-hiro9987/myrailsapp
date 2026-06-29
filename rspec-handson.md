# RSpec ハンズオン手順書

## 1. gem の追加

`Gemfile` の `group :development, :test` に以下を追加する：

```ruby
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end
```

## 2. bundle install

コンテナ内で実行：

```bash
bundle install
```

## 3. RSpec の初期化

```bash
bin/rails generate rspec:install
```

以下のファイルが生成される：
- `.rspec` — RSpec のオプション設定
- `spec/spec_helper.rb` — RSpec 本体の設定
- `spec/rails_helper.rb` — Rails との統合設定

## 4. .rspec の設定

`.rspec` を以下の内容にする：

```
--require spec_helper
--format documentation
--color
```

## 5. Factory の作成

`spec/factories/` ディレクトリにテストデータの雛形を作成する。

### spec/factories/users.rb

```ruby
FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid_#{n}" }
    provider { "github" }
    sequence(:name) { |n| "user#{n}" }
    image_url { "https://example.com/avatar.png" }
  end
end
```

### spec/factories/events.rb

```ruby
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
```

### spec/factories/tickets.rb

```ruby
FactoryBot.define do
  factory :ticket do
    association :user
    association :event
    comment { "参加します！" }
  end
end
```

## 6. rails_helper.rb の設定

`spec/rails_helper.rb` に FactoryBot の設定を追加する：

```ruby
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods  # この行を追加
  # ... 既存の設定 ...
end
```

---

## 7. モデルスペックを書く

`spec/models/` にファイルを作成する。

### spec/models/event_spec.rb

テストしたいこと：
- バリデーション（必須項目、文字数制限）
- `start_at_should_be_before_end_at` カスタムバリデーション
- `created_by?` メソッド

```ruby
require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'バリデーション' do
    context '正常なデータの場合' do
      it '有効であること' do
        event = build(:event)
        expect(event).to be_valid
      end
    end

    context 'name が空の場合' do
      it '無効であること' do
        event = build(:event, name: '')
        expect(event).not_to be_valid
      end
    end

    context 'name が51文字以上の場合' do
      it '無効であること' do
        event = build(:event, name: 'a' * 51)
        expect(event).not_to be_valid
      end
    end

    context 'place が空の場合' do
      it '無効であること' do
        event = build(:event, place: '')
        expect(event).not_to be_valid
      end
    end

    context 'content が空の場合' do
      it '無効であること' do
        event = build(:event, content: '')
        expect(event).not_to be_valid
      end
    end

    context 'start_at が end_at より後の場合' do
      it '無効であること' do
        event = build(:event, start_at: 2.weeks.from_now, end_at: 1.week.from_now)
        expect(event).not_to be_valid
        expect(event.errors[:start_at]).to include('は終了時間よりも前に設定してください')
      end
    end

    context 'start_at と end_at が同じ場合' do
      it '無効であること' do
        time = 1.week.from_now
        event = build(:event, start_at: time, end_at: time)
        expect(event).not_to be_valid
      end
    end
  end

  describe '#created_by?' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:event) { create(:event, owner: owner) }

    context '作成者が渡された場合' do
      it 'true を返すこと' do
        expect(event.created_by?(owner)).to be true
      end
    end

    context '別のユーザが渡された場合' do
      it 'false を返すこと' do
        expect(event.created_by?(other_user)).to be false
      end
    end

    context 'nil が渡された場合' do
      it 'false を返すこと' do
        expect(event.created_by?(nil)).to be false
      end
    end
  end
end
```

### spec/models/ticket_spec.rb

テストしたいこと：
- `comment` のバリデーション（文字数、空白許可）

```ruby
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'バリデーション' do
    context '正常なデータの場合' do
      it '有効であること' do
        ticket = build(:ticket)
        expect(ticket).to be_valid
      end
    end

    context 'comment が空の場合' do
      it '有効であること（空白を許可）' do
        ticket = build(:ticket, comment: '')
        expect(ticket).to be_valid
      end
    end

    context 'comment が31文字以上の場合' do
      it '無効であること' do
        ticket = build(:ticket, comment: 'a' * 31)
        expect(ticket).not_to be_valid
      end
    end
  end
end
```

### spec/models/user_spec.rb

テストしたいこと：
- 未終了イベントがある場合は退会できないこと

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '退会（削除）' do
    let(:user) { create(:user) }

    context '未終了の作成イベントがある場合' do
      it '削除できないこと' do
        create(:event, owner: user, start_at: 1.day.from_now, end_at: 2.days.from_now)
        expect { user.destroy }.not_to change(User, :count)
      end
    end

    context '終了済みのイベントしかない場合' do
      it '削除できること' do
        create(:event, owner: user, start_at: 2.days.ago, end_at: 1.day.ago)
        expect { user.destroy }.to change(User, :count).by(-1)
      end
    end
  end
end
```

---

## 8. リクエストスペックを書く

`spec/requests/` にファイルを作成する。

### spec/requests/events_spec.rb

テストしたいこと：
- ログインしていないと一覧以外アクセスできないこと
- ログイン済みならイベントを作成・編集・削除できること

```ruby
require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:event) { create(:event, owner: user) }

  # ログインを模倣するヘルパー（後述）
  def login(u)
    post "/auth/github/callback", env: { "omniauth.auth" => OmniAuth::AuthHash.new({
      provider: u.provider,
      uid: u.uid,
      info: { nickname: u.name, image: u.image_url }
    }) }
  end

  describe "GET /events" do
    it "200 を返すこと" do
      get events_path
      expect(response).to redirect_to(root_path)  # 未ログインはリダイレクト
    end
  end

  describe "GET /events/:id" do
    it "ログインなしでもイベント詳細を見られること" do
      get event_path(event)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /events" do
    context 'ログイン済みの場合' do
      before { login(user) }

      it 'イベントを作成できること' do
        expect {
          post events_path, params: {
            event: {
              name: "テストイベント",
              place: "東京",
              content: "内容",
              start_at: 1.week.from_now,
              end_at: 2.weeks.from_now
            }
          }
        }.to change(Event, :count).by(1)
      end
    end

    context '未ログインの場合' do
      it 'root にリダイレクトされること' do
        post events_path, params: { event: attributes_for(:event) }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
```

---

## 9. テストの実行

```bash
# 全テスト
bundle exec rspec

# モデルスペックのみ
bundle exec rspec spec/models/

# ファイル指定
bundle exec rspec spec/models/event_spec.rb

# 特定の行のみ（例: 15行目のテスト）
bundle exec rspec spec/models/event_spec.rb:15
```

---

## よく使う RSpec のマッチャー

| マッチャー | 意味 |
|---|---|
| `expect(x).to be_valid` | バリデーションが通る |
| `expect(x).not_to be_valid` | バリデーションが通らない |
| `expect(x).to eq(y)` | x と y が等しい |
| `expect(x).to be true / be false` | 真偽値の確認 |
| `expect { }.to change(Model, :count).by(1)` | レコード数が1増える |
| `expect(response).to have_http_status(:ok)` | ステータスコードが200 |
| `expect(response).to redirect_to(path)` | リダイレクト先の確認 |
| `include('文字列')` | 配列や文字列に含まれる |
