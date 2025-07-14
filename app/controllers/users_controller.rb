class UsersController < ApplicationController
  def show
    @user = current_user
    @user_flower = UserFlower.find_by(user: @user)
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user, notice: "更新しました"
    else
      render :edit
    end
  end

  def ranking
    @ranked_users = User.all.sort_by(&:total_record_duration_hours).reverse
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password)
  end

  def create_user_flower
    UserFlower.create(user: self)
end
end
