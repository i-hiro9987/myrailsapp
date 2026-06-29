class Event < ApplicationRecord
  # 基本的にhasmanyと書いてある方が多で、belongs_toでは１側
  # dependent: destroyではこのクラスを削除した場合、最初に指定したモデルを削除。
  # 要はイベントを削除するとそれに伴い、関連する参加チケットも自動的に削除しますよ的な意味合い
  has_many :tickets, dependent: :destroy
  belongs_to :owner, class_name: "User"

  # ここはバリデーション系
  # validates: 個別のカラムに対して。
  # validate:　関数を指定できる
  # lengthは文字の長さ。presence: trueは入力必須
  validates :name, length: { maximum: 50 }, presence: true
  validates :place, length: { maximum: 100 }, presence: true
  validates :content, length: { maximum: 2000 }, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :start_at_should_be_before_end_at

  # ここは指定したユーザによって作成されましたか？というのを確認している。
  # 仮にユーザの指定がなければ早期リターンでfalse
  # ユーザが存在していて、尚且つユーザのIDとオーナーIDが一致すればTrue
  # でもそもそもOwnerIDはどこから来ているのか
  def created_by?(user)
    return false unless user
    owner_id == user.id
  end

  private

  # ここでは開始時間と終了時間が反転していないかを確認している。
  # もし設定されていなければ早期リターン
  # もし反転していれば、エラー群にエラー内容を追加する。
  def start_at_should_be_before_end_at
    return unless start_at && end_at

    if start_at >= end_at
      errors.add(:start_at, "は終了時間よりも前に設定してください")
    end
  end
end
