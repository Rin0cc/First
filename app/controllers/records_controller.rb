class RecordsController < ApplicationController
  before_action :set_or_create_user_flower

  def new
    @record = Record.new
  end

  def create
    time_in_seconds = params[:time].to_i

    if time_in_seconds < 1800
      flash[:alert] = "30分以上じゃないと記録できないよ"
      redirect_to new_record_path
      return
    end

    @record = Record.new(
      time: time_in_seconds,
      task_name: record_params[:task_name],
      user: current_user,
      user_flower: @user_flower
    )

    if @record.save
      update_flower_status!
      redirect_to new_record_path
    else
      flash.now[:alert] = "記録に失敗しました"
      render :new
    end
  end

  private

  def set_or_create_user_flower
    @user_flower = current_user.user_flowers.first_or_create(status: "none")
  end

  def record_params
    params.require(:record).permit(:task_name)
  end

  def update_flower_status!
    @user_flower.reload

    previous_status = @user_flower.status

    record_days = @user_flower.records
                 .pluck(:created_at)
                 .map { |t| t.in_time_zone("Asia/Tokyo").to_date }
                 .uniq
    day_count = record_days.count

    new_status = case day_count
                 when 1 then "seed"
                 when 2 then "sprout"
                 when 3..6 then "bud"
                 when 7 then "full_bloom"
                 else previous_status
                 end

    if previous_status != new_status
      @user_flower.update(status: new_status)

      case new_status
      when "seed"
        flash[:notice] = "🪴 花の種を取得しました"
        flash[:flower_image] = "Flowerseeds.png"
      when "sprout"
        flash[:notice] = "🌱 花の芽が出ました"
        flash[:flower_image] = "Sprout.png"
      when "bud"
        flash[:notice] = "💧 花に水やりしました"
        flash[:flower_image] = "Bud.png"
      when "full_bloom"
        flash[:notice] = "🌸 花が咲きました！"
        flash[:flower_image] = ["FullBloom1.png", "FullBloom2.png"].sample
      end
    else
      flash[:notice] = "✨ 記録ありがとう！"
      flash[:flower_image] = "Thanks.png"
    end
  end
end
