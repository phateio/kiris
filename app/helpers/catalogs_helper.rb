module CatalogsHelper
  def render_catalog_google_sheets_edit_link
    link_to t('catalogs.edit_with_google_sheets'), 'https://goo.gl/3lbOef', target: "_blank"
  end
end
