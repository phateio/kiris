module CatalogsHelper
  def render_catalog_html(catalog)
    return simple_content('N/A') if catalog.nil?
    render partial: 'catalog_html'
  end

  def render_catalog_edit_link
    return unless @access > 0
    link_to t('form.edit'), edit_catalog_path(@catalog), remote: true
  end

  def render_catalog_form
    render partial: 'catalog_form'
  end
end
