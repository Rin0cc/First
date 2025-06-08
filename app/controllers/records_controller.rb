class RecordsController < ApplicationController
  before_action :set_user_flower
  def new
    @record = @user_flower.records.build
  end

  def create
    @record = @user_flower.records.build(record_params)
    @record.user = current_user
    if @record.save
      redirect_to new_user_flower_record_path(@user_flower), notice: "記録しました"
    else
      render :new
    end
  end
  
  private

  def set_user_flower
    @user_flower = UserFlower.find(params[:user_flower_id])
  end

  def record_params
    params.require(:record).permit(:task_name)
  end
end
