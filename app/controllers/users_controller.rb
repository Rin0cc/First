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

  private
    def user_params
      params.require(:user).permit(:name, :email, :password)
  end

  def create_user_flower
    UserFlower.create(user:self)
end
end
