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
        message: "✨ 記録ありがとう！（30分以上から花は育つよ）",
        image: ActionController::Base.helpers.image_url("Thanks.png")
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

      message, image_file_name, new_flower_id = update_flower_status

      render json: {
        status: "success",
        message: message,
        image: ActionController::Base.helpers.image_url(image_file_name),
        new_flower_id: new_flower_id
      }
    else
      render json: {
        status: "error",
        message: "記録ありがとう✨",
        image: ActionController::Base.helpers.image_url("Thanks.png")
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
    new_flower_id_for_js = nil

    if @user_flower.records.empty?
      @user_flower.update(status: :seed)
      return [ "🪴 花の種を取得しました", "Flowerseeds.png", new_flower_id_for_js ]
    end

    record_days = @user_flower.records
                              .pluck(:created_at)
                              .map { |t| t.in_time_zone("Asia/Tokyo").to_date }
                              .uniq

    day_count = record_days.count

    case day_count
    when 1
      @user_flower.update(status: :seed)
      [ "🪴 花の種を取得しました", "Flowerseeds.png", new_flower_id_for_js ]
    when 2
      @user_flower.update(status: :sprout)
      [ "🌱 花の芽が出ました", "Sprout.png", new_flower_id_for_js ]
    when 3
      @user_flower.update(status: :bud)
      [ "💧 花に水やりしました", "Bud.png", new_flower_id_for_js ]
    when 4
      @user_flower.update(status: :bud)
      [ "💧 花に水やりしました", "Bud.png", new_flower_id_for_js ]
    when 5
      @user_flower.update(status: :bud)
      [ "💧 花に水やりしました", "Bud.png", new_flower_id_for_js ]
    when 6
      @user_flower.update(status: :bud)
      [ "💧 花に水やりしました", "Bud.png", new_flower_id_for_js ]
    when 7
      @user_flower.update(status: :full_bloom)
      new_flower = current_user.user_flowers.create(
        flower: Flower.first,
        status: :waiting
      )
      new_flower_id_for_js = new_flower.id if new_flower.persisted?

      [ "🌸 花が咲きました！", [ "FullBloom1.png", "FullBloom2.png" ].sample.to_s, new_flower_id_for_js ]
    else
      [ "✨ 記録ありがとう！花は成長中だよ！", "Thanks.png", new_flower_id_for_js ]
    end
  end

  def record_params
    params.require(:record).permit(:task_name)
  end
end