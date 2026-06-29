class TicketsController < ApplicationController
  # newアクションは使用しない設計（イベント詳細ページから直接createへPOST）
  # ただしルーティングには残っているため、誤アクセス時にエラーを出す
  def new
    # 親クラスのルーティングエラー呼び出し？
    # -> Ans: ActionController::RoutingErrorは Rails の例外クラス。newアクションは使用しないので、誤アクセス時にエラーを発生させています。
    raise ActionController::RoutingError, "ログイン状態で TicketsController#new にアクセス"
  end

  # イベント作成機能

  def create
    # イベントを作成する。
    # URLの中のパスを取得し、event_idのパラメータを元にイベントを取得
    event = Event.find(params[:event_id])
    # 未記名参加チケットを作成し、それをtとして定義
    @ticket = current_user.tickets.build do |t|
      # tのイベント情報は先ほど取得したイベント情報を記載
      t.event = event
      # tのチケットに参加コメントを記載。この情報はパラメータ情報から読み取る。
      t.comment = params[:ticket][:comment]
    end
    # もしチケットが保存できたらイベントページに遷移させ、OKメッセージも渡す
    if @ticket.save
      redirect_to event, notice: "このイベントに参加表明しました"
    end
  end

  # 参加をキャンセル。参加チケットを破り捨てて無効化。
  # まずはそのチケット情報を取得する必要があり、今ログインしているユーザが持っているチケットの中からイベントIDを指定し探し出す。
  # 見つかった場合は削除？エクスクラメーションマークがあるけどなかった場合はどうなるのか？
  # -> Ans: find_by!は見つからない場合ActiveRecord::RecordNotFoundを発生させます。!なしはnilを返すだけ。
  # その後、パラメータで指定したイベントIDを元に、そのイベントページに飛ばし、キャンセルしたことをメッセージで伝える。
  # ちなみにイベントパスにIDを指定するとそのページに飛ばせる機能がRailsにはある？
  # -> Ans: 正解。event_path(id)でイベント詳細ページのパスを生成します。Railsのルーティングヘルパー機能です。
  def destroy
    ticket = current_user.tickets.find_by!(event_id: params[:event_id])
    ticket.destroy!
    redirect_to event_path(params[:event_id]), notice: "このイベントの参加をキャンセルしました"
  end
end
