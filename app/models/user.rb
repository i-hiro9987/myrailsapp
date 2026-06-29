class User < ApplicationRecord
  # ここは何の処理をしているんだ？
  # -> Ans: before_destroyはコールバック。ユーザ削除前にcheck_all_events_finishedメソッドを実行します。
  before_destroy :check_all_events_finished

  # ここのcreated_eventsは何なのだろう？でもクラス名はEventで、外部キーはowner_idか。dependentで指定されているものは？
  # -> Ans: created_eventsは関連名(自分が作成したイベント)。Eventテーブルのowner_idで紐付け。dependent: :nullifyはユーザ削除時にowner_idをnullにします。
  has_many :created_events, class_name: "Event", foreign_key: "owner_id", dependent: :nullify

  # 一人のユーザは複数のイベントへの参加チケットを持つことができる。nullifyに関してはどういう意味？
  # -> Ans: dependent: :nullifyはユーザ削除時にチケットのuser_idをnullにします(チケット自体は削除されない)。
  has_many :tickets, dependent: :nullify

  # participating_eventsというのもどこででてきたかわかっていない。しかし、この情報を取る時はイベント情報を元にチケット情報を取得している？
  # -> Ans: through関連。ticketsを経由してeventを取得します。user.participating_eventsで参加しているイベント一覧を取得可能。
  has_many :participating_events, through: :tickets, source: :event

  # ここでのselfは親クラスのメソッドを使用している？どこで定義されていたっけ？
  # -> Ans: selfはクラスメソッドの定義。ActiveRecordのfind_or_create_by!を使用(親クラスで定義済み)。
  # おそらく内容としては、認証情報を元に、必要な情報を取り出す。
  # もし情報がなければ新たに作成だし、存在しているならそのまま探し出したユーザ情報を渡す。
  # ここでネームやイメージURLはGithub上などで書き換わる情報の可能性があるので、ここでは更新？のようにしているのかな？
  # -> Ans: 正解。ブロック内でnameとimage_urlを更新することで、既存ユーザの情報も最新化します。
  def self.find_or_create_from_auth_hash!(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]
    nickname = auth_hash[:info][:nickname]
    image_url = auth_hash[:info][:image]

    User.find_or_create_by!(provider: provider, uid: uid) do |user|
      user.name = nickname
      user.image_url = image_url
    end
  end

  private

  # ここは何をしている場所なのか？
  # -> Ans: ユーザ削除前に未終了イベントがあるかチェック。あればエラーを追加してthrow(:abort)で削除をキャンセル。
  # こういう何だろう？みたいな関数や処理があったときはどう追っていけばいい？
  # -> Ans: ①メソッド名で検索 ②呼び出し元を確認(before_destroyなど) ③Railsガイドでコールバック/関連を調べる ④実際に動かしてログを見る
  def check_all_events_finished
    now = Time.zone.now
    if created_events.where(":now < end_at", now: now).exists?
      errors[:base] << "公開中の未終了イベントが存在します。"
    end

    if participating_events.where(":now < end_at", now: now).exists?
      errors[:base] << "未終了の参加イベントが存在します。"
    end

    throw(:abort) unless errors.empty?
  end
end
