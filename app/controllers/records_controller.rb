class RecordsController < ApplicationController
  before_action :set_user_flower

  def new
    @record = @user_flower.records.build
  end

  def create
    time_in_seconds = params[:time].to_i

    if time_in_seconds < 1800
      flash[:alert] = "30分以上じゃないと記録できないよ"
      redirect_to new_user_flower_record_path(@user_flower), status: :see_other
      return
    end

    @user_flower ||= current_user.user_flowers.create(
      flower: Flower.first,
      status: :waiting  )

    @record = @user_flower.records.build(
      time: time_in_seconds,
      task_name: record_params[:task_name]
    )
    @record.user = current_user

    if @record.save
  flash[:flower_image] = "Thanks.png"
  @user_flower.reload

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

    # 🌸 新しい花を育て始める
    default_flower = Flower.first
    new_flower = current_user.user_flowers.create(flower: default_flower, status: :waiting) if default_flower
  else
    flash[:notice] = "✨ 記録ありがとう！"
    flash[:flower_image] = "Thanks.png"
  end

  # 💡 満開後は新しい花へ、そうでなければ今の花へ
  redirect_to new_user_flower_record_path(new_flower || @user_flower)
end
  end

  private

def set_user_flower
  @user_flower =
    current_user.user_flowers
                .where.not(status: :full_bloom)
                .order(created_at: :desc)
                .first ||
    current_user.user_flowers
                .where(status: :waiting)
                .order(created_at: :desc)
                .first

  # 花がなくてもOKに変更（リダイレクトを消す）
end


  def record_params
    params.require(:record).permit(:task_name)
  end
end
