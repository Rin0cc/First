#
google_credentials = Rails.application.credentials.google

Rails.application.config.middleware.use OmniAuth::Builder do
  # Google OAuth2 プロバイダの設定
  # credentials.yml からクライアントIDとシークレットを読み込んでいます
  provider :google_oauth2, google_credentials[:client_id], google_credentials[:client_secret]
end
