$(document).on 'click', '#noticeform .js-button-new', (event) ->
  $self = $(event.currentTarget)
  $target = $('#noticeform .js-notice-list')
  responseText = $('#noticeform .template-notice-item').html()
  $target.prepend(responseText)
