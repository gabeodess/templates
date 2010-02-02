PAYPAL_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/paypal_config.yml")[RAILS_ENV]
APP_CONFIG.merge!(PAYPAL_CONFIG)