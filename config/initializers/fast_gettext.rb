FastGettext.add_text_domain 'app', path: Rails.root.join("config/locales").to_s, type: :po
FastGettext.default_available_locales = %w[en]
FastGettext.default_text_domain = 'app'

I18n.locale = FastGettext.locale.to_sym
