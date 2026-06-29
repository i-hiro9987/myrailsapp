class EventsController < ApplicationController
  # 別にイベント情報を参照するのにはユーザ認証機能は必要ないのかも
  skip_before_action :authenticate, only: :show

  # イベント詳細ページを見るもの。
  # イベントの情報はイベントクラスに対し、パラメータにあるイベントIDを元に探す。
  # チケットに関しては今ログインしていて、持っているチケットの中からこのイベントのものを探す。
  # イベントに紐づけられている参加者チケットたちを探す。そしてインクルードをしているのはどういう言い回しなんだ？
  # -> Ans: includes(:user)はN+1問題対策。チケットと関連するユーザ情報を一括取得し、クエリ数を削減します。
  def show
    @event = Event.find(params[:id])
    @ticket = current_user && current_user.tickets.find_by(event: @event)
    @tickets = @event.tickets.includes(:user).order(:created_at)
  end

  # イベント作成をするが、空のイベント。枠だけある的な感じか？
  # -> Ans: 正解。フォーム表示用の空オブジェクトを作成します。
  # そしてカレントユーザとすることでログインしているかどうかも確認できて、空イベントのみ作成か？しかしcreated_eventsなのは何なのかわかんないんだけど？
  # -> Ans: created_eventsはuser.rbで定義した関連(has_many)。owner_idが自動設定されたEventオブジェクトをbuildします。
  def new
    @event = current_user.created_events.build
  end

  # イベントアップデート用。ここではイベントのIDを指定して保存されているイベント情報をビューに渡す。
  def edit
    @event = current_user.created_events.find(params[:id])
  end

  # 編集用ページから呼ばれたらアップデート処理が走る
  # イベント情報を取得し、パラメータ情報から更新をかける。もしアップデートできなかったら、編集用ページに飛ばす。
  def update
    @event = current_user.created_events.find(params[:id])
    if @event.update(event_params)
      redirect_to @event, notice: "更新しました"
    end
  end

  # ここでもcreated_eventsは何なのか？
  # -> Ans: 上記と同じ。user.rbのhas_many :created_eventsで定義された関連です。
  # 今回は作成後、event_paramsで埋め込むデータを入れている。あれ？Create的なの直でしないんだっけ？
  # -> Ans: buildで作成してsaveする方式。バリデーション失敗時に@eventを再利用できます。
  # そのあとsaveで分岐わけするためか？
  # -> Ans: 正解。saveの成功/失敗で処理を分岐します。
  # saveが通れば、イベントページに飛ばし、通らなければまた空のイベント作成ページなのか？中のデータはまた入れ直しなのか？
  # -> Ans: 失敗時は@eventに入力値とエラー情報が残っているので、フォームに再表示されます。
  def create
    @event = current_user.created_events.build(event_params)
    if @event.save
      redirect_to @event, notice: "作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # イベントを削除する処理
  # イベント情報をIDから取得し、削除を試みる。
  # ここでもエクスクラメーションがあるがどう働く？
  # -> Ans: destroy!は削除失敗時に例外を発生させます。destroy(!なし)はfalseを返すだけ。
  # 削除後はルートに飛ばす
  def destroy
    @event = current_user.created_events.find(params[:id])
    @event.destroy!
    redirect_to root_path, notice: "削除しました"
  end

  # ここのプライベートっていうのは外部から呼べないようにしているんだよね？
  # -> Ans: 正解。privateメソッドはクラス内部からのみ呼び出せます。ルーティングから直接アクセスされるのを防ぎます。
  private

  # パラメータに埋め込まれた情報を取得する。ここでのpermitはセキュリティー上だっけ？
  # -> Ans: 正解。Strong Parametersによるセキュリティ機能。許可した属性のみ受け取り、不正な一括代入を防ぎます。
  def event_params
    params.require(:event).permit(
      :name, :place, :content, :start_at, :end_at
    )
  end
end
