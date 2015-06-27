$(document).on 'submit', '.image-instance form', (event) ->
  event.preventDefault()
  $self = $(this)
  $.ajax
    url: '/admin/images/edit'
    type: 'POST'
    data: $(this).serialize()
    dataType: 'json'
    success: ->
      $self.closest('table').fadeOut 600, ->
        $self.remove()
