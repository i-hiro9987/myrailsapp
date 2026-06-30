require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'バリデーション' do
    context '正常なデータの場合' do
      it '有効であること' do
        ticket = build(:ticket)
        debugger
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
