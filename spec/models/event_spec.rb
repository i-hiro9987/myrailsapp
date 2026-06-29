require 'rails_helper'

RSpec.describe Event, type: :model do
  # describeは大分類テスト
  # contextは状態（文脈）を記載
  # itは小テスト
  # expect.toはXXXであることを保証
  # 逆に.not_toはXXXでないことを保証
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

  # letはテストケース内で使える変数定義
  # -> 補足: 遅延評価（lazy evaluation）で定義される。実際に呼ばれるまで実行されない。
  # ->       let!にすると即時評価（定義した時点で実行）になる。DBへの事前登録が必要な場合はlet!を使う。
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
