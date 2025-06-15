require_relative "boot"
require "rails/all"

# Gemfileのgemを読み込む
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Rails 7.2 のデフォルト設定を読み込む
    config.load_defaults 7.2

    # デフォルトの言語を日本語に設定
    config.i18n.default_locale = :ja

    # タイムゾーンを東京に設定（ここに移動！）
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    config.autoload_lib(ignore: %w[assets tasks])

    # その他の設定
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
