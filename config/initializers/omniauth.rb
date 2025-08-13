google_credentials = Rails.application.credentials.google

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, google_credentials[:client_id], google_credentials[:client_secret]
end
