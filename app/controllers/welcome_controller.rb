class WelcomeController < ApplicationController
  # ここでスキップしないと、トップページもログイン必須になってしまうのでミドルウェアをスキップ
  skip_before_action :authenticate

  # トップページ表示
  def index
    # イベント情報を今現在開催中のものに絞って取得→開始時間の昇順
    @events = Event.where("start_at > ?", Time.zone.now).order(:start_at)
  end
end
