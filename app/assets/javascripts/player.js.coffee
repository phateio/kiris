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

$(document).ready ->
  $player = $('#jquery_jplayer_1')

  $player.jPlayer
    ready: ->
      DEBUG('jPlayer: ready')
      $this = $(this)
      user_volume = memcache.get('volume')
      user_muted = memcache.get('muted')
      $this.jPlayer('volume', user_volume) unless isNaN(user_volume)
      $this.jPlayer('mute', user_muted) unless isNaN(user_muted)
      $this.trigger('reload')

    play: ->
      DEBUG('jPlayer: play')
      $this = $(this)
      $this.data('playing', true)

    pause: ->
      DEBUG('jPlayer: pause')
      $this = $(this)
      $this.data('playing', false)
      $this.trigger('reload')

    progress: (event) ->
      DEBUG('jPlayer: progress')
      $this = $(this)
      $this.trigger('ping')

    timeupdate: (event) ->
      DEBUG('jPlayer: timeupdate')
      $this = $(this)
      $this.trigger('ping')

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

    supplied: 'oga, mp3'
    solution: 'html'
    swfPath: '/'
    preload: 'none'
    wmode: 'window'
    keyEnabled: true
    keyBindings:
      fullScreen: false
      loop: false

  $player.on 'reload', ->
    DEBUG('jPlayer: reload')
    $this = $(this)
    listen_path =
      oga: "/listen.ogg?_=#{$.now()}"
      mp3: "/listen.mp3?_=#{$.now()}"
    is_playing = $this.data('playing')

    $this.jPlayer('clearMedia')
    $this.jPlayer('setMedia', listen_path)
    if is_playing
      $this.jPlayer('play')
    else
      old_timeout_id = $this.data('timeout-id')
      clearTimeout(old_timeout_id)

  $player.on 'ping', ->
    $this = $(this)
    old_timeout_id = $this.data('timeout-id')
    clearTimeout(old_timeout_id)
    new_timeout_id = setTimeout ->
      $this.trigger('ping')
      $this.trigger('reload')
    , rand(10, 30) * 1000
    $this.data('timeout-id', new_timeout_id)

  $('#jp_container_1 .jp-volume-bar-container').on 'mousewheel DOMMouseScroll', (event) ->
    event.preventDefault()
    delta = event.originalEvent.wheelDelta or event.originalEvent.detail * -40
    DEBUG('Mousewheel delta: ' + delta)
    volume = $player.jPlayer('option', 'volume') + if delta > 0 then 0.05 else -0.05
    $player.jPlayer('volume', volume)
