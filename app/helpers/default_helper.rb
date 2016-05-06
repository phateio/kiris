module DefaultHelper
  def render_preferences_i18n_form
    render partial: 'preferences_i18n_form'
  end

  def render_preferences_keybind
    render partial: 'preferences_keybind'
  end

  private

  def locale_options_for_select
    options_for_select(locale_options, I18n.locale)
  end

  def locale_options
    [
      ['English', 'en'],
      ['Japanese - 日本語', 'ja'],
      ['Chinese (Simplified Han) - 简体中文', 'zh-Hans'],
      ['Chinese (Traditional Han) - 繁體中文', 'zh-Hant']
    ]
  end
end
