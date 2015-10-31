$(document).on 'ready', ->

  $(document).on 'submit', '#lang_area form', (event) ->
    event.preventDefault()
    $self = $(event.currentTarget)
    if $self.triggerHandler('beforesubmit') == false
      return false
    type = event.currentTarget.getAttribute('method') || 'GET'
    location_path = if type.toUpperCase() == 'GET' then window.location.pathname else window.location.href
    href = event.currentTarget.getAttribute('action') || location_path
    data = $self.serialize()

    $.ajax
      url: href
      data: data
      type: type
      complete: ->
        document.location = document.location

  $(document).on 'click', '#speed .js-button-start', (event) ->
    $self = $(this)
    $button_stop = $self.parents().find('.js-button-stop')
    $video = $self.parents().find('video')
    _video = $video.get(0)
    filesize = 22241976
    starttime = Math.floor($.now() / 1000)

    $video.attr('src', '//stream.phate.io/video/sm17289336.mp4?_=' + $.now())
    $video.on 'progress', (event) ->
      return if not _video.buffered.length >= 1
      buffered = Math.ceil(_video.buffered.end(0))
      duration = Math.ceil(_video.duration)
      progress = buffered / duration
      nowtime = Math.floor($.now() / 1000)
      elapsedTime = nowtime - starttime
      downrate = Math.floor(progress * filesize / 1024 / elapsedTime)
      $('#speed .downrate').text("#{downrate} KiB/s")

    _video.play()
    _video.play()

    $self.attr('disabled', 'disabled')
    $button_stop.removeAttr('disabled')

  $(document).on 'click', '#speed .js-button-stop', (event) ->
    $self = $(this)
    $button_start = $self.parents().find('.js-button-start')
    $video = $self.parents().find('video')
    _video = $video.get(0)
    _video.pause()
    $video.removeAttr('src')

    $self.attr('disabled', 'disabled')
    $button_start.removeAttr('disabled')
