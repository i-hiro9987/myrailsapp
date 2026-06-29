class Ticket < ApplicationRecord
  # チケットに対してユーザは一人なのでbelongs_to
  # optional: trueとは何なのか？
  # -> Ans: userが存在しなくてもチケットを保存可能にします(匿名参加など)。デフォルトではbelongs_toは必須です。
  # チケットに対してイベントも一つなのでここもbelongs_to
  belongs_to :user, optional: true
  belongs_to :event

  # コメントは文字数制限をかけつつも、空白は許可している。
  validates :comment, length: { maximum: 30 }, allow_blank: true
end
