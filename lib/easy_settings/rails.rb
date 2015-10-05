class EasySettings
  class Railtie < ::Rails::Railtie
    initializer "easy_settings" do |app|
      EasySettings.namespace   ||= Rails.env
      EasySettings.source_file ||= Rails.root.join("config/settings.yml").to_s
    end
  end
end
