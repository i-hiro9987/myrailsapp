class SessionsController < ApplicationController
  # なぜセッションのところで認証一部オフなの？全部オフではない？結局セッションのところで認証が走るのか？どういう流れなのか？
  # -> Ans: createはログイン処理なので、未ログイン状態でアクセスする必要があります。only: :createでcreateアクションのみ認証スキップ。
  skip_before_action :authenticate, only: :create

  # セッションを作成する
  # ユーザ工場(クラス)に問い合わせる。指定された認証情報が存在するかどうか？存在すればそれに対応するユーザ情報を返すし、なければ新たにユーザを作成し返す
  # このrequest.envは何なのか？
  # -> Ans: request.envはRackの環境変数ハッシュ。OmniAuthが認証情報を"omniauth.auth"キーに格納します。
  # セッション情報のユーザIDに取得したユーザ情報のIDを格納しセッション情報とする
  # ルートパスにリダイレクト
  def create
    user = User.find_or_create_from_auth_hash!(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path, notice: "ログインしました"
  end

  # ユーザのセッションをリセットし、ログアウトとする。
  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました"
  end
end
