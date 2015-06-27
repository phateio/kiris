$(document).on 'click', '.image-instance>tbody>tr>th>a', (event) ->
  MOUSE_LEFT = 1
  return if event.which != MOUSE_LEFT
  event.preventDefault()
  timer.background(this.href)

$(document).on 'click', '.js-preview', (event) ->
  imgurl = $('#new_image #image_url').val()
  timer.background(imgurl)
