$(document).on 'playlist:resize', '#playing li[id]', (event) ->
  $self = $(event.currentTarget)
  $dummy = $self.clone()

  # TODO: function
  $dummy.addClass('dummy')
  $(document.body).append($dummy)
  self_width = $dummy.width()
  $dummy.remove()

  margin_left = 34
  timeleft_width = 112
  margin_padding = margin_left

  listeners_offset_left = $('#listeners').offset().left
  max_width = listeners_offset_left - margin_padding

  $self.css('max-width',  max_width)
  $self.find('.artist, .title').css('max-width',  (max_width - timeleft_width) * 0.5)

$(document).on 'click', '#playing li:first-child', ->
  $self = $(this).parent()
  return if String(getSelected())

  if $self.hasClass('playlist-expanded')
    $self.animate {'height': '30'}, 600, ->
      $self.css('height', '').removeClass('playlist-expanded')
  else
    $self.addClass('playlist-expanded')

.on 'click', '#playing li:not(:first-child)', ->
  $self = $(this).parent()
  return if String(getSelected())

  timer.refresh(global: true)
  $self.addClass('playlist-expanded')

$(document).on 'click', '#listeners', ->
  $(window).trigger('page:refresh', global: true)

$(window).ready ->
  playing = false
  callback = false

  $.jPlayer.reload = ->
    DEBUG('jPlayer: reload')
    $self = $(this)
    playing = false
    volume = memcache.get('volume')
    muted = memcache.get('muted')
    $self.jPlayer('destroy')
    $self.jPlayer($.jPlayer.config)
    $self.jPlayer('volume', volume) unless isNaN(volume)
    $self.jPlayer('mute', muted) unless isNaN(muted)

  $.jPlayer.restart = ->
    DEBUG('jPlayer: restart')
    $self = $(this)
    callback = ->
      setTimeout ->
        $self.jPlayer('play')
      , rand(1, 5) * 1000
    $.jPlayer.reload.call(this)

  $.jPlayer.config =
    ready: ->
      DEBUG('jPlayer: ready')
      $self = $(this)
      stream = mp3: '/listen?_=' + $.now()
      $self.jPlayer('setMedia', stream)
      callback() if callback

    play: ->
      DEBUG('jPlayer: play')
      playing = true

    pause: ->
      DEBUG('jPlayer: pause')
      callback = false
      $(this).jPlayer('clearMedia')
      $.jPlayer.reload.call(this)

    stalled: ->
      return unless playing
      DEBUG('jPlayer: stalled')

    ended: ->
      return unless playing
      DEBUG('jPlayer: ended')
      $.jPlayer.restart.call(this)

    suspend: ->
      return unless playing
      DEBUG('jPlayer: suspend')
      $.jPlayer.restart.call(this)

    abort: ->
      return unless playing
      DEBUG('jPlayer: abort')
      $.jPlayer.restart.call(this)

    emptied: ->
      return unless playing
      DEBUG('jPlayer: emptied')
      $.jPlayer.restart.call(this)

    stop: ->
      return unless playing
      DEBUG('jPlayer: stop')
      $.jPlayer.restart.call(this)

    error: (event) ->
      return unless playing
      DEBUG('jPlayer: error: ' + event.jPlayer.error.type)
      $.jPlayer.restart.call(this)

    volumechange: (event) ->
      $self = $(this)
      volume_new = event.jPlayer.options.volume
      volume_old = memcache.get('volume')
      muted = $self.jPlayer('option', 'muted')
      if volume_old != undefined && volume_new.toFixed(2) == volume_old.toFixed(2)
        DEBUG('jPlayer: mute')
        memcache.set('muted', muted)
        return
      DEBUG('jPlayer: volume: ' + volume_new.toFixed(2))
      memcache.set('volume', volume_new)
      if muted
        DEBUG('jPlayer: unmute')
        $self.jPlayer('mute', false)

    supplied: 'mp3'
    solution: 'html'
    swfPath: '/'
    preload: 'none'
    wmode: 'window'
    keyEnabled: true
    keyBindings:
      fullScreen: false
      loop: false

  $jquery_jplayer_1 = $('#jquery_jplayer_1')

  $('#jp_container_1 .jp-volume-bar-container').on 'mousewheel DOMMouseScroll', (event) ->
    event.preventDefault()
    delta = event.originalEvent.wheelDelta or event.originalEvent.detail * -40
    DEBUG('Mousewheel delta: ' + delta)
    volume = $jquery_jplayer_1.jPlayer('option', 'volume') + if delta > 0 then 0.05 else -0.05
    $jquery_jplayer_1.jPlayer('volume', volume)

  $.jPlayer.reload.call($jquery_jplayer_1)
