class RetirementsController < ApplicationController
  # 退会用のコントローラだがここでNewがある理由は？
  # -> Ans: RESTful設計。newは退会確認画面、createは実際の退会処理。Railsでは削除もリソースとして扱います。
  # おそらく確認画面なのではないか？Createの方はAPI的な？
  # -> Ans: 正解。newが確認画面、createが実処理です。API的というより、RESTfulなリソース操作の分離です。
  def new
  end

  # 退会を作るのか？と思われるが、何だっけ？責務の分離だっけ？もし退会したらリセットセッションでセッションもリセットするし、ルートパスに飛ばす。
  # -> Ans: 正解。退会をリソースとして扱い、責務を分離。成功時はセッションリセット&リダイレクト。
  def create
    if current_user.destroy
      reset_session
      redirect_to root_path, notice: "退会完了しました"
    end
  end
end
