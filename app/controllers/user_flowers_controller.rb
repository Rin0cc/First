class UserFlowersController < ApplicationController
  before_action :authenticate_user! # ログインしているユーザーだけがアクセスできるようにする

  # 花図鑑ページのアクション
  def encyclopedia
    @encyclopedia_flowers = current_user.user_flowers.where(status: :full_bloom).order(created_at: :desc)
  end

  # 必要であれば、他のアクションもここに追加する
  # 例:
  # def index
  #   @user_flowers = current_user.user_flowers.all
  # end
end
