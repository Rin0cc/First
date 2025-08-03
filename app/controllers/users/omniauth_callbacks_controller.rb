# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # Userモデルのfrom_omniauthメソッドを呼び出してユーザーを検索または作成します
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      # ユーザーが存在するか、正常に作成された場合
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      # ユーザーが作成できなかった場合（例: バリデーションエラー）
      # Deviseの内部エラーではないため、登録ページにリダイレクトします
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    # 認証に失敗した場合、このメソッドが呼び出されます
    # ユーザーをトップページにリダイレクトし、エラーメッセージを表示します
    redirect_to root_path, alert: '認証に失敗しました。'
  end
end
