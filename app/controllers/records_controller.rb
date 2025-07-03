class RecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_flower
  before_action :set_record, only: [:update, :destroy, :edit]

  def new
    @record = @user_flower.records.build
    @records = current_user.records.where(completed: false).order(created_at: :desc)
  end

  def create
    time_in_seconds = record_params[:time].to_i

    # ToDo追加フォームからの送信か、時間記録フォームからの送信かを判断
    is_todo_only_submission = record_params[:task_name].present? && time_in_seconds == 0

    if !is_todo_only_submission && time_in_seconds < 1800
      flash[:alert] = "✨ 記録ありがとう！（30分以上から花は育つよ）"
      flash[:flower_image] = "Thanks.png"
      redirect_to new_record_path
      return
    end

    @record = @user_flower.records.build(record_params.merge(user: current_user))

    respond_to do |format|
      if @record.save
        @user_flower.reload

        # 花の状態更新とFlashメッセージの設定は、time_in_seconds が 1800 以上の場合のみ行う
        if !is_todo_only_submission && time_in_seconds >= 1800
          message, image_file_name, new_flower_id_for_js = update_flower_status
          flash[:notice] = message
          flash[:flower_image] = image_file_name
          flash[:new_flower_id] = new_flower_id_for_js
        end

        format.html { redirect_to new_record_path }
        format.turbo_stream do
          if is_todo_only_submission
            # ToDo追加の場合：新しいToDoをリストの先頭に追加し、フォームをリセット
            render turbo_stream: [
              turbo_stream.prepend("todo_items", partial: "records/record", locals: { record: @record }),
              turbo_stream.replace("record_errors", partial: "shared/error_messages", locals: { resource: @record }), # エラー表示をクリア
              turbo_stream.update("new_record_form", partial: "records/form", locals: { record: Record.new }) # フォームをリセット
            ]
          else
            # 時間記録の場合は、HTMLリダイレクトと同じ効果（ページ全体をリロード）
            render turbo_stream: turbo_stream.action(:redirect, new_record_path)
          end
        end
      else
        flash.now[:alert] = "ToDoの作成に失敗しました。内容を確認してください。"
        @records = current_user.records.where(completed: false).order(created_at: :desc)
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("record_errors", partial: "shared/error_messages", locals: { resource: @record })
        end
      end
    end
  end

  def edit
  end

  def index
    redirect_to new_record_path
  end

  def update
    if @record.update(record_params)
      render json: { status: 'success', message: 'ToDoが更新されました！', completed: @record.completed }
    else
      render json: { status: 'error', message: @record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    redirect_to new_record_path, notice: 'ToDoが削除されました。'
  end

  private

  def set_user_flower
    @user_flower =
      current_user.user_flowers
                  .where.not(status: :full_bloom)
                  .or(current_user.user_flowers.where(status: :waiting))
                  .order(created_at: :desc)
                  .first

    @user_flower ||= current_user.user_flowers.create(
      flower: Flower.first,
      status: :waiting
    )
  end

  def update_flower_status
    new_flower_id_for_js = nil

    if @user_flower.records.empty?
      @user_flower.update(status: :seed)
      return ["🪴 花の種を取得しました", "Flowerseeds.png", new_flower_id_for_js]
    end

    record_days = @user_flower.records
                              .pluck(:created_at)
                              .map { |t| t.in_time_zone("Asia/Tokyo").to_date }
                              .uniq

    day_count = record_days.count

    case day_count
    when 1
      @user_flower.update(status: :seed)
      ["🪴 花の種を取得しました", "Flowerseeds.png", new_flower_id_for_js]
    when 2
      @user_flower.update(status: :sprout)
      ["🌱 花の芽が出ました", "Sprout.png", new_flower_id_for_js]
    when 3..6
      @user_flower.update(status: :bud)
      ["💧 花に水やりしました", "Bud.png", new_flower_id_for_js]
    when 7
      @user_flower.update(status: :full_bloom)
      new_flower = current_user.user_flowers.create(
        flower: Flower.first,
        status: :waiting
      )
      new_flower_id_for_js = new_flower.id if new_flower.persisted?

      ["🌸 花が咲きました！", ["FullBloom1.png", "FullBloom2.png"].sample.to_s, new_flower_id_for_js]
    else
      ["✨ 記録ありがとう！花は成長中だよ！", "Thanks.png", new_flower_id_for_js]
    end
  end

  def record_params
    # ユーザーちゃんのコードで正しいです！
    params.require(:record).permit(:task_name, :completed, :time, :user_flower_id, :completed)
  end

  def set_record
    @record = current_user.records.find(params[:id])
  end
end