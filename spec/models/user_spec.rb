require 'rails_helper'

# なぜcreate, buildを使うのか？
# -> Ans: build はDBに保存しない仮オブジェクトを作成する。バリデーションのテストなど保存が不要な場合に使う（高速）。
# ->      create はDBに実際に保存する。関連モデルの参照や、削除・件数変化など実際のDB操作が必要なテストで使う（低速）。
# ->      つまり「DBへの保存が必要かどうか」で使い分ける。

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
