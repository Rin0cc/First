class UsersController < ApplicationController
  def show
    @user = current_user
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)  # user_paramsで安全に受け取る
      redirect_to @user, notice: "更新しました"
    else
      render :edit
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password)
  end
end
