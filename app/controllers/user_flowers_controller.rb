class UserFlowersController < ApplicationController
  before_action :authenticate_user!

  def encyclopedia
    # 💡 修正: where(status: :full_bloom) を削除
    @encyclopedia_flowers = current_user.user_flowers.order(created_at: :desc)
  end
end
