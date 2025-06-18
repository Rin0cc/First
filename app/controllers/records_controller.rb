class RecordsController < ApplicationController
  before_action :set_user_flower

  def new
    @record = @user_flower.records.build
  end

def create
  time_in_seconds = params[:time].to_i

  if time_in_seconds < 1800
    render json: {
      status: "short_time",
      message: "✨ 記録ありがとう！（30分未満だと花は育たないよ）"
    }
    return
  end

  @record = @user_flower.records.build(
    time: time_in_seconds,
    task_name: record_params[:task_name],
    user: current_user
  )

  if @record.save
    @user_flower.reload
    message, image = update_flower_status

    render json: {
      status: "success",
      message: message,
      image: image
    }
  else
    render json: {
      status: "error",
      message: "記録ありがとう✨"
    }, status: :unprocessable_entity
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
    ["🪴 花の種を取得しました", "Flowerseeds.png"]
  when 2
    @user_flower.update(status: :sprout)
    ["🌱 花の芽が出ました", "Sprout.png"]
  when 3..6
    @user_flower.update(status: :bud)
    ["💧 花に水やりしました", "Bud.png"]
  when 7
    @user_flower.update(status: :full_bloom)
    @next_flower = current_user.user_flowers.create(
      flower: Flower.first,
      status: :waiting
    )
    ["🌸 花が咲きました！", ["FullBloom1.png", "FullBloom2.png"].sample]
  else
    ["✨ 記録ありがとう！", "Thanks.png"]
  end
end


  def record_params
    params.require(:record).permit(:task_name)
  end
end
