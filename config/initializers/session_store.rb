Rails.application.config.session_store :cookie_store,
  key: '_blooming_record_session',
  domain: Rails.env.production? ? 'bloomingrecord.com' : nil,
  same_site: :lax,
  secure: Rails.env.production?
