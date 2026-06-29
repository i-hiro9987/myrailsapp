class ApplicationController < ActionController::Base
  # どのコントローラにアクセスしても認証を必須とする。(スキップ以外)
  # ヘルパーメソッドを定義することによってビューからも呼べるようになる。
  # でも何でlogged_in?やカレントユーザはプライベートなんだ？
  # -> Ans: privateにしてhelper_methodで公開するのが慣習。コントローラ間の不要な呼び出しを防ぎます。
  # 出しておけば見れるじゃん？セキュリティー上？
  # -> Ans: セキュリティというより設計の問題。必要な場所(ビュー)のみに公開し、意図しない依存を防ぎます。
  before_action :authenticate
  helper_method :logged_in?, :current_user

  private

  # ここはログインしていますか？を返す。
  # エクスクラメーションが２つなのは、
  # 仮にユーザが特定できた→いない→いる
  # 仮にユーザが特定できない→いる→いない
  # 確かここってtrue, falseのような判別しやすい形式にしてるんだっけ？
  # -> Ans: 正解。!!で明示的にboolean(true/false)に変換します。nilやオブジェクトではなく真偽値を返すため。
  def logged_in?
    !!current_user
  end

  # セッション情報からユーザが特定できなければ早期リターンし未ログインであることを伝える。
  # ２行目はなんだ？今ログインしているユーザ情報を取得するんだろうけど、、？セッション情報のユーザIDからユーザを探して見つからなければnil?
  # -> Ans: 正解。||=はメモ化パターン。既に取得済みなら再検索せず、未取得ならDBから取得します。リクエスト内で何度呼んでもクエリは1回のみ。
  def current_user
    return unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  # 認証をする。
  # 仮にログイン状態なら認証は通っているので早期リターン
  # そうでなければリターンではないのでログインページにリダイレクト
  def authenticate
    return if logged_in?
    redirect_to root_path, alert: "ログインしてください"
  end
end
