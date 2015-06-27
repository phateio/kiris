module ImagesHelper
  def get_userip_with_tripcode(userip)
    userip.empty? ? 'Member' : tripcode(userip)
  end

  def get_userip_with_tripcode_and_admin_address_peek(image)
    if @access > 5
      content_tag :span, get_userip_with_tripcode(image.userip), data: {tooltips_text: image.userip}
    else
      get_userip_with_tripcode(image.userip)
    end
  end

  def render_image_rules
    render partial: 'images/image_rules'
  end

  def render_image_form(image)
    render partial: 'images/image_form', :locals => {image: image}
  end

  def render_image_list(images)
    render partial: 'images/image_list', :locals => {images: images}
  end

  def render_image_list_item(image)
    render partial: 'images/image_list_item', :locals => {image: image}
  end

  def render_image_status_msg(image)
    return 'N/A' if image.status_msg.empty?
    t("images.status_msg.#{image.status_msg}")
  end

  def render_image_edit_link(image)
    return unless @access > 0
    link_to t('form.edit'), admin_image_path(image), remote: true
  end
end
