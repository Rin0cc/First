# config/application.rb

require "rails"
# 必要なフレームワークのみを require
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"
require "rails/test_unit/railtie"
# require "sprockets/railtie" # ここは引き続きコメントアウトのまま！
require "rails/command"
# require "rails/health/railtie"
require "omniauth/rails_csrf_protection"

# Gemfileのgemを読み込む
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    config.load_defaults 7.2

    config.i18n.default_locale = :ja
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    config.autoload_lib(ignore: %w[assets tasks])

    # ここにPropshaftの設定を追加または確認！ ↓
    # 開発環境とテスト環境でPropshaftを有効にする
    config.assets.enabled = true # アセットパイプライン自体を有効にする
    config.assets.precompile = [] # Sprocketsのプリコンパイルは行わない
    config.assets.paths << Rails.root.join("app/assets/builds") # ★ESbuildの出力先をアセットパスに追加

    # もし Propshaft の Gem (propshaft) を Gemfile に追加していない場合は、追加する必要がある
    # Gemfile に gem "propshaft" があるか確認してね
  end
end
