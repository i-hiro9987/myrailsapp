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
