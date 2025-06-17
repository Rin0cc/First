class RecordsController < ApplicationController
  before_action :set_user_flower

  def new
    @record = @user_flower.records.build
  end

  def create
    time_in_seconds = params[:time].to_i

    if time_in_seconds < 1800
      flash[:alert] = "30分以上じゃないと記録できないよ"
      redirect_to new_user_flower_record_path, status: :see_other
      return
    end

    @record = @user_flower.records.build(
      time: time_in_seconds,
      task_name: record_params[:task_name],
      user: current_user
    )

    if @record.save
      @user_flower.reload
      update_flower_status
      redirect_to new_user_flower_record_path(@next_flower || @user_flower)
    else
      flash[:alert] = "記録に失敗しました"
      render :new, status: :unprocessable_entity
    end
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
    record_days = @user_flower.records
                              .pluck(:created_at)
                              .map { |t| t.in_time_zone("Asia/Tokyo").to_date }
                              .uniq
    day_count = record_days.count

    case day_count
    when 1
      @user_flower.update(status: :seed)
      flash[:notice] = "🪴 花の種を取得しました"
      flash[:flower_image] = "Flowerseeds.png"
    when 2
      @user_flower.update(status: :sprout)
      flash[:notice] = "🌱 花の芽が出ました"
      flash[:flower_image] = "Sprout.png"
    when 3..6
      @user_flower.update(status: :bud)
      flash[:notice] = "💧 花に水やりしました"
      flash[:flower_image] = "Bud.png"
    when 7
      @user_flower.update(status: :full_bloom)
      flash[:notice] = "🌸 花が咲きました！"
      flash[:flower_image] = ["FullBloom1.png", "FullBloom2.png"].sample

      @next_flower = current_user.user_flowers.create(
        flower: Flower.first,
        status: :waiting
      )
    else
      flash[:notice] = "✨ 記録ありがとう！"
      flash[:flower_image] = "Thanks.png"
    end
  end

  def record_params
    params.require(:record).permit(:task_name)
  end
end
