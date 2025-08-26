class RecordsController < ApplicationController
  # ログイン済みのユーザーのみアクセス可能
  before_action :authenticate_user!

  # 特定のレコードを取得するアクション
  before_action :set_record, only: [ :update, :destroy, :edit, :show ]

  # ユーザーのお花をセットする（なければ新しく作成）
  before_action :set_user_flower, except: [ :update, :destroy, :show, :analytics ]

  # 新しいToDoのフォームとToDoリストを表示する
  def new
    # @user_flowerが存在する場合のみ、レコードをビルドする
    if @user_flower.present?
      @record = @user_flower.records.build
      # 未完了のToDoを新しい順に取得
      @records = @user_flower.records.incomplete.order(created_at: :desc)
      # 完了済みのToDoを古い順に取得
      @completed_records = @user_flower.records.completed.order(created_at: :desc)
    else
      # @user_flowerが存在しない場合は、空のレコードを生成
      @record = Record.new
      @records = []
      @completed_records = []
    end
  end

  # ToDoの追加または時間記録の作成
  def create
    # ストロングパラメータを使って新しいレコードを初期化
    @record = Record.new(record_params)

    # ユーザーと花を明示的に紐付け
    # ここで必ずuser_idとuser_flower_idをセットすることで、NullViolationを防ぐ
    @record.user_id = current_user.id
    @record.user_flower_id = @user_flower.id

    # ToDo追加のみか、時間記録かを判別
    is_todo_only_submission = record_params[:task_name].present? && record_params[:time].to_i == 0
    time_in_seconds = record_params[:time].to_i

    # 時間記録の場合で30分未満の処理
    if !is_todo_only_submission && time_in_seconds < 1800
      flash[:alert] = "✨ 記録ありがとう！（30分以上から花は育つよ）"
      flash[:flower_image] = "Thanks.png"
      respond_to do |format|
        format.html { redirect_to new_record_path }
        # Turbo Streamでリダイレクトを処理することで、ページ全体のリロードを避ける
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, new_record_path) }
      end
      return
    end

    respond_to do |format|
      if @record.save
        if is_todo_only_submission
          # Turbo Streamで新しいToDoをリストに追加し、フォームをリセット
          format.html { redirect_to new_record_path(anchor: "todo-list") }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.prepend("todo_items", partial: "records/record", locals: { record: @record }),
              turbo_stream.replace("record_errors", partial: "shared/error_messages", locals: { resource: @record }),
              # フォームを更新する際、user_flower_idがセットされた新しいRecordオブジェクトを渡す
              turbo_stream.update("new_record_form", partial: "records/form", locals: { record: @user_flower.records.build })
            ]
          end
        else # 時間記録の場合
          @user_flower.reload
          message, image_file_name, new_flower_id_for_js = update_flower_status
          flash[:notice] = message
          flash[:flower_image] = image_file_name
          flash[:new_flower_id] = new_flower_id_for_js
          # HTMLリダイレクトと同じ効果（ページ全体をリロード）
          format.html { redirect_to new_record_path }
          format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, new_record_path) }
        end
      else # 保存失敗時のエラーハンドリング
        # @recordsを再取得してビューに渡す
        @records = current_user.records.where(completed: false).order(created_at: :desc)
        if is_todo_only_submission
          # Turbo Streamでエラーメッセージだけを更新する
          format.html { render :new, status: :unprocessable_entity }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("record_errors", partial: "shared/error_messages", locals: { resource: @record })
          end
        else
          flash[:alert] = "時間記録の保存に失敗しました。"
          format.html { redirect_to new_record_path }
          format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, new_record_path) }
        end
      end
    end
  end

  def edit
  end

  def show
  end

  def index
    # 通常、indexはレコードの一覧を表示するが、このアプリではnewにリダイレクト
    redirect_to new_record_path
  end

  # アナリティクス画面のデータを準備する
  def analytics
    # Chart.js 用のデータ準備 (日ごとの合計記録時間)
    user_records = current_user.records.where.not(time: nil)

    daily_total_times = user_records.group("DATE(created_at)").sum(:time)

    @chart_data = daily_total_times.map do |date, total_seconds|
      {
        date: date.to_s,
        totalDurationMinutes: (total_seconds / 60.0).round(1)
      }
    end.to_json.html_safe

    # FullCalendar.io 用のデータ準備 (個々の記録をイベントとして)
    @calendar_events = user_records.map do |record|
      start_time = record.created_at
      # 記録終了日時 (開始日時 + 記録時間)
      end_time = start_time + record.time.seconds

      {
        title: "#{record.task_name.presence || '記録'} (#{record.time / 60}分)",
        start: start_time.iso8601,
        end: end_time.iso8601,
        allDay: false,
        id: record.id
      }
    end.to_json.html_safe
  end

  # ToDoの完了ステータスを更新する（APIとして使用）
def update
  if @record.update(record_params)
    # 更新に成功したら、Turbo Streamでレコードを置き換える
    respond_to do |format|
      format.html { redirect_to new_record_path } # フォールバック
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@record, partial: "records/record", locals: { record: @record })
      end
    end
  else
    # エラー時のレスポンスをTurbo Streamで返す
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity } # フォールバック
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("record_errors", partial: "shared/error_messages", locals: { resource: @record })
      end
    end
  end
end

  # ToDoを削除する
  def destroy
    @record.destroy
    # ToDo追加時と同様に、リダイレクトではなくTurbo Streamで処理
    respond_to do |format|
      format.html { redirect_to new_record_path, notice: "ToDoが削除されました。" }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@record) }
    end
  end

  private

  # ユーザーのお花をセットする（なければ作成）
  def set_user_flower
    # ユーザーに紐づく、満開（:full_bloom）でない最新のお花を取得
    @user_flower = current_user.user_flowers.find_by(status: [ :waiting, :seed, :sprout, :bud ])

    # ユーザーのお花が見つからない場合
    if @user_flower.nil?
      # `Flower`モデルにレコードが一つもない場合、自動的にデフォルトのお花を作成します。
      # すでにある場合は最初のお花を取得します。
      default_flower = Flower.first_or_create(name: "ひまわり")

      # 既存の花も自動作成した花も取得できなかった場合はエラー
      if default_flower.nil?
        # このエラーは通常発生しないはずですが、念のため残しておきます。
        flash[:alert] = "花のデータが見つかりません。管理者に連絡してください。"
        redirect_to root_path and return
      end

      # デフォルトのお花を使って、新しい`UserFlower`を作成します。
      @user_flower = current_user.user_flowers.create(flower: default_flower, status: :waiting)

      # 作成に失敗した場合のハンドリング
      unless @user_flower.persisted?
        flash[:alert] = "花の作成に失敗しました。管理者に連絡してください。"
        redirect_to root_path and return
      end
    end
  end

  # 花の状態を更新し、メッセージと画像を返す
  def update_flower_status
    record_days = @user_flower.records
                              .pluck(:created_at)
                              .map { |t| t.in_time_zone("Asia/Tokyo").to_date }
                              .uniq

    day_count = record_days.count

    new_flower_id_for_js = nil

    case day_count
    when 1
      @user_flower.update(status: :seed)
      [ "🪴 花の種を取得しました", "Flowerseeds.png", new_flower_id_for_js ]
    when 2
      @user_flower.update(status: :sprout)
      [ "🌱 花の芽が出ました", "Sprout.png", new_flower_id_for_js ]
    when 3..6
      @user_flower.update(status: :bud)
      [ "💧 花に水やりしました", "Bud.png", new_flower_id_for_js ]
    when 7
      @user_flower.update(status: :full_bloom)
      # 満開になったら新しい花（待ちの状態）を作成する
      new_flower = current_user.user_flowers.create(flower: Flower.first, status: :waiting)
      new_flower_id_for_js = new_flower.id if new_flower.persisted?

      [ "🌸 花が咲きました！", [ "FullBloom1.png", "FullBloom2.png" ].sample.to_s, new_flower_id_for_js ]
    else
      [ "✨ 記録ありがとう！花は成長中だよ！", "Thanks.png", new_flower_id_for_js ]
    end
  end

  # ストロングパラメータ
  def record_params
    params.require(:record).permit(:task_name, :completed, :time, :user_flower_id)
  end

  # 現在のユーザーに紐づくレコードを取得
  def set_record
    @record = current_user.records.find(params[:id])
  end
end
