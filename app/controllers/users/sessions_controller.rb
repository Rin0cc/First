class Users::SessionsController < Devise::SessionsController
  def guest_sign_in
    unless params[:key] == ENV["secret_key_record"]
      return redirect_to new_user_session_path, alert: "ゲストログイン権限がありません"
    end

    user = User.guest
    sign_in user
    redirect_to root_path, notice: "ゲストユーザーとしてログインしました。"
  end
end
