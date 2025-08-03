class TasksController < ApplicationController
  # ログインしているユーザーのみがアクセスできるようにする
  before_action :authenticate_user!

  def index
    # ログイン中のユーザーのタスク（record）を全て取得し、作成日時の新しい順に並び替える
    @records = current_user.records.order(created_at: :desc)

    # 検索キーワードが入力されている場合は、タスク名で絞り込み検索をする
    if params[:search].present?
      @records = @records.search(params[:search])
    end

    # 取得したタスクを「未完了」と「完了済み」に分ける
    @incomplete_records = @records.incomplete
    @completed_records = @records.completed
  end

  # タスクの完了・未完了を切り替えるアクション
  def toggle_completion
    # ユーザーのタスクの中から、指定されたIDのタスクを見つける
    @record = current_user.records.find(params[:id])
    # タスクの`completed`ステータスを反転させて更新する
    @record.update(completed: !@record.completed)
    # タスク一覧ページにリダイレクトし、メッセージを表示する
    redirect_to tasks_path, notice: "タスクの状態を更新したよ！"
  end
end