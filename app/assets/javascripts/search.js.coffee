# include 'memcache'

$(document).on 'refresh', '.search-list .request a[data-track-id]', (event) ->
  $self = $(event.currentTarget)
  datetime = $self.data('nexttime') || 0
  nexttime = new Date(datetime * 1000)
  if (new Date()) > nexttime
    $self.removeClass('disabled')
  else
    $self.addClass('disabled')
  $self.attr('title', nexttime)

$(document).on 'click', '.search-list .request a[data-track-id]', (event) ->
  event.preventDefault()
  $self = $(event.currentTarget)
  $tooltips = $('#tooltips')
  $target = $self.parent('[data-tooltips-text]')
  $loadimg = $self.parent().find('img')
  track_id = $self.data('track-id')
  nickname = memcache.get('nickname')
  $tooltips.text('-') if window.tooltips_src == $target.get(0)

  $self.hide()
  $loadimg.show()

  $(document).queue 'ajaxRequests', ->
    $.ajax
      url: '/request.json'
      type: 'POST'
      dataType: 'json'
      data:
        track_id: track_id
        nickname: nickname
      global: false
      timeout: 60000
      beforeSend: ->
      success: (item) ->
        $self.data('nexttime', item.nexttime) if item.nexttime
        $target.data('tooltips-text', item.message)
        $tooltips.text(item.message) if window.tooltips_src == $target.get(0)
        $('.search-list .request a[data-track-id]').trigger('refresh')
      complete: ->
        $loadimg.hide()
        $self.show()
        ga('send', 'event', 'button', 'click', 'search:request', track_id)
        $(document).dequeue('ajaxRequests')
        if $(document).queue('ajaxRequests').length == 0
          window.ajax_request = false

  if window.ajax_request != true && $(document).queue('ajaxRequests').length > 0
    window.ajax_request = true
    $(document).dequeue('ajaxRequests')
