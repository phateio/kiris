module Admin::ImagesHelper
  def render_admin_image_list_item(image)
    render partial: 'admin_image_list_item', :locals => {image: image}
  end

  def render_admin_image_list_item_form(image)
    render partial: 'admin_image_list_item_form', :locals => {image: image}
  end
end
