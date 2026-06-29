require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:event) { create(:event, owner: user) }

  # ここの処理はどこで使用されている？
  # -> Ans: 下の「before { login(user) }」で使用されている。beforeブロックはitの実行前に毎回呼ばれる前処理。
  def login(u)
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: u.provider,
      uid: u.uid,
      info: { nickname: u.name, image: u.image_url }
    )
    get "/auth/github/callback"
  end

  describe "GET /events/new" do
    # ここでは変数などに入れなくてもレスポンスなどを確認（入れること）が可能？
    # -> Ans: 正解。`response`はリクエストスペックで自動的に使えるオブジェクト。getやpostを呼んだ後の結果が入っている。
    it "未ログインの場合 root にリダイレクトされること" do
      get new_event_path
      expect(response).to redirect_to(root_path)
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
