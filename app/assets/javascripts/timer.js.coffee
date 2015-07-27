# include 'memcache'

class @Timer
  constructor: ->
    self = this
    self.tid = false
    self.playlist = []
    self.backimg_url = false
    self.backimg_success = false
    self.background_tid = false
    self.unique = false
    self.track_id = false
    self.image_url = false
    self.image_source = false
    self.image_illustrator = false
    self.image_element = false
    self.prefix = 'pli_'
    self.nexttime = 0
    self.duration = 0
    self.callback = false
    self.fast = 600
    self.normal = 1000
    self.slow = 3000
    self.root = window || this

  start: =>
    self = this
    return if self.tid
    self.tid = setInterval ->
      self.countdown()
    , 500

  stop: =>
    self = this
    return if not self.tid
    clearTimeout(self.tid)
    self.tid = false

  reset: =>
    self = this
    nowtime = Math.floor($.now() / 1000)
    self.track_id = self.playlist[0].track_id
    self.image_url = self.playlist[0].image.url
    self.image_source = self.playlist[0].image.source
    self.image_illustrator = self.playlist[0].image.illustrator
    if self.playlist[0].timeleft > 0
      self.unique = "#{self.prefix}#{self.playlist[0].id}"
      self.nexttime = nowtime + self.playlist[0].timeleft
      self.duration = self.playlist[0].duration
    else
      self.unique = false
      self.nexttime = nowtime + rand(10, 30)
      self.duration = self.playlist[0].duration

  metainfo: (text, option = {}) =>
    self = this
    if text
      $('#playing').append("<li class=\"metainfo hidden\">#{text}</li>")
      $('#playing>li.metainfo').slideDown(self.fast)
    else if option.clearStatus
      $('#playing>li.metainfo').slideUp self.fast, ->
        $(this).remove()

  countdown: =>
    self = this
    nowtime = Math.floor($.now() / 1000)
    timeleft = self.nexttime - nowtime
    timeleft_min = Math.floor(timeleft / 60)
    timeleft_sec = Math.floor(timeleft % 60)
    if timeleft < 0
      past = self.playlist.shift()
      if self.playlist.length > 0 && self.unique
        self.reset()
        self.scrollUp(clearAll: false)
        self.otherUpdate(duration: null, evalCallback: true)
        self.metainfo('Loading . . .') if self.playlist.length == 1
      else
        self.unique = false
        self.nexttime = nowtime + rand(30, 60)
        self.refresh()
      return
    return if not self.unique
    elapsed_time = self.duration - timeleft
    danmaku.sync(elapsed_time)
    timeleft_sec = '0' + timeleft_sec if timeleft_sec < 10
    $("##{self.unique} .timeleft").text("#{timeleft_min}:#{timeleft_sec}")

  refresh: (options = {}) =>
    self = this
    settings =
      url: '/playlist.json'
      dataType: 'json'
      cache: false
      global: false
      success: (data) ->
        self.metainfo(null, clearStatus: true)
        self.metainfo('Loading . . .') if self.playlist.length == 0
        return if data.length == 0
        if self.playlist.length > 0 && self.playlist[0].id == data[0].id
          self.playlist = data
          self.reset()
          self.scrollUp(clearAll: false)
          self.otherUpdate(duration: null, evalCallback: false)
          self.queueUpdate()
        else if new Date(Date.parse(data[0].playedtime)) > new Date(0)
          self.playlist = data
          self.reset()
          self.scrollUp(clearAll: true)
          self.otherUpdate(duration: null, evalCallback: false)
          self.queueUpdate()
        self.metainfo('Random playing . . .') if self.playlist.length == 1
    $.extend(settings, options)
    $.ajax(settings)

  scrollUp: (options = {}) =>
    self = this
    options.duration = self.normal if not options.duration
    if options.clearAll
      $('#playing>li').removeAttr('id').slideUp options.duration, ->
        $(this).remove()
    else
      $("##{self.unique}").prevAll().removeAttr('id').slideUp options.duration, ->
        $(this).remove()

  otherUpdate: (options = {}) =>
    self = this
    options.duration = self.slow if not options.duration
    self.callback() if options.evalCallback && self.callback
    return if self.playlist.length == 0
    return if $('#backimg_front').length == 0
    self.background(self.image_url, self.image_illustrator).always ->
      self.background_preload()

#   # doodle
#   timeleft = self.playlist[0].timeleft
#   hash = self.playlist[0].hash
#   playing_state = !$('#jquery_jplayer_1').find('audio').get(0).paused
#   muted_state = $('#jquery_jplayer_1').jPlayer('option', 'muted')
#   if hash == '2bd3a17124714774b1f796c014b18463cf41fbc4' && playing_state == true && muted_state == false
#     $('#jquery_jplayer_1').jPlayer('mute', true)
#     $('.embedded-background').fadeIn(5000).removeClass('hidden')
#     $('#jquery_jplayer_2').jPlayer('play')
#     danmaku.size = 2.0
#   else if hash == '2bd3a17124714774b1f796c014b18463cf41fbc4' && timeleft > 30
#     $('.embedded-background').fadeIn(5000).removeClass('hidden')
#     $('#jquery_jplayer_2').jPlayer('mute', true).jPlayer('play', 232 - timeleft)
#     danmaku.size = 2.0
#   else if not $('.embedded-background').hasClass('hidden')
#     $('.embedded-background').fadeOut(5000).addClass('hidden')
#     $('#jquery_jplayer_2').jPlayer('stop')
#     $('#jquery_jplayer_1').jPlayer('mute', false)
#     danmaku.size = null

  queueUpdate: (options = {}) =>
    self = this
    $playing_li = $('#playing>li')
    options.duration = self.normal if not options.duration
    for li, i in $playing_li
      id = $(li).attr('id')
      if self.playlist[i] && id != "#{self.prefix}#{self.playlist[i].id}"
        $("##{id}").prev().nextAll().removeAttr('id').slideUp options.duration, ->
          $(this).remove()
        break
    for item in self.playlist
      id = "#{self.prefix}#{item.id}"
      artist = item.artist || 'Null'
      title = item.title
      tags = item.tags
      timeleft = item.timeleft
      duration = item.duration
      continue if document.getElementById(id) isnt null
      template = $.trim($('#template-playing-li').html())
      timeleft_min = Math.floor(timeleft / 60)
      timeleft_sec = Math.floor(timeleft % 60)
      duration_min = Math.floor(duration / 60)
      duration_sec = Math.floor(duration % 60)
      timeleft_sec = '0' + timeleft_sec if timeleft_sec < 10
      duration_sec = '0' + duration_sec if duration_sec < 10
      html = template.replace(/{{id}}/g, id)
                     .replace(/{{artist}}/g, artist)
                     .replace(/{{title}}/g, title)
                     .replace(/{{tags}}/g, tags)
                     .replace(/{{timeleft}}/g, timeleft_min + ':' + timeleft_sec)
                     .replace(/{{duration}}/g, duration_min + ':' + duration_sec)
      $('#playing').append(html)
      $("##{id}").slideDown(options.duration)
    $('#playing li[id]').trigger('playlist:resize')

  background: (image_url, image_illustrator= null) =>
    self = this
    deferred = $.Deferred()
    self.image_element = $(document.createElement('img'))
    if not memcache.get('background')
      if image_url == self.root.asseturls.default_image
        DEBUG('background: Disabled')
        deferred.resolve()
        return deferred.promise()
      image_url = self.root.asseturls.default_image
    image_url = image_url || self.root.asseturls.default_image
    image_status = if self.backimg_success && self.backimg_url == image_url then 'Skip' else 'Change'
    DEBUG("background: '#{self.backimg_url}' => '#{image_url}' (#{self.backimg_success}, #{image_status})")
    if image_status == 'Skip'
      self.background_before_action()
      self.background_after_action(image_illustrator)
      deferred.resolve()
    else
      self.backimg_url = image_url
      self.backimg_success = false
      self.background_before_action()
      self.image_element.on 'load', ->
        DEBUG('background: onload')
        return if self.backimg_url != image_url
        if self.image_element.get(0).width < 200 || self.image_element.get(0).height < 200
          DEBUG('background: image size error')
          self.image_element.trigger('error')
          return
        deferred.resolve()
        self.background_swap(image_url)
        self.background_after_action(image_illustrator)
        self.backimg_success = true
      self.image_element.on 'abort error', ->
        DEBUG('background: onerror')
        return if self.backimg_url != image_url
        self.background_rescue_action()
        deferred.reject()
        self.backimg_success = false
      self.image_element.attr('src', image_url)
    return deferred.promise()

  background_preload: =>
    self = this
    if self.playlist.length > 1
      new_image_url = self.playlist[1].image.url || self.root.asseturls.default_image
      image_preload_element = $(document.createElement('img'))
      image_preload_element.attr('src', new_image_url)
      image_preload_element.on 'load', ->
        DEBUG("background: Preload '#{new_image_url}' onload")
      image_preload_element.on 'error', ->
        DEBUG("background: Preload '#{new_image_url}' onerror")

  background_swap: (image_url) =>
    self = this
    DEBUG("background: '#{image_url}'")
    $backimg_front = $('#backimg_front')
    $backimg_back = $('#backimg_back')
    background_image = if image_url == 'none' then 'none' else "url(#{image_url})"
    $backimg_back.css('background-image', background_image)
    $backimg_back.attr('id', 'backimg_front').css('zIndex', -20)
    $backimg_front.attr('id', 'backimg_back').css('zIndex', -30)

  background_setTimeout: =>
    self = this
    if self.background_tid
      clearTimeout(self.background_tid)
      self.background_tid = false
    self.background_tid = setTimeout(->
      return if not self.background_tid
      image_url = self.image_element.attr('src')
      DEBUG("background: Load '#{image_url}' timeout")
      self.image_element.removeAttr('src')
      self.image_element.trigger('error')
    , 30 * 1000)

  background_before_action: =>
    self = this
    self.background_setTimeout()
    $('#image-info').hide()
    $('#lyrics').html('<span>Loading . . .</span>')

  background_after_action: (image_illustrator) =>
    self = this
    if self.background_tid
      clearTimeout(self.background_tid)
      self.background_tid = false
    if image_illustrator
      template = $.trim($('#template-image-info').html())
      html = template.replace(/{{source_url}}/g, self.image_source)
                     .replace(/{{illustrator}}/g, htmlspecialchars(image_illustrator))
    else
      html = ''
    $('#image-info').html(html).show()
    self.lyrics()

  background_rescue_action: =>
    self = this
    self.background_swap('data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=')
    self.background_after_action()

  lyrics: =>
    self = this
    if self.playlist.length == 0 || not memcache.get('lyrics')
      $('#lyrics').html('')
      return false
    raw_lyrics = self.playlist[0].lyrics
    raw_lyrics_lines = raw_lyrics.split('\n')
    lyrics = raw_lyrics.replace(/\[[\w\.: ]+\]\s*/g, '')  # [00:00.00]
                       .replace(/<[\w\.: ]+>\s*/g, '// ')  # <00:00.00>
    $('#lyrics').html('').append($('<pre></pre>',
      html: lyrics
      lang: 'ja'
    ))
    danmaku_lyrics = []
    for raw_lyrics_line in raw_lyrics_lines
      if matches = /<(\d{2,})\:(\d{2})(?:\.(\d{2,3}))?>\s*(.*)/.exec(raw_lyrics_line)
        minutes = parseInt(matches[1])
        seconds = parseInt(matches[2])
        time = minutes * 60 + seconds
        text = matches[4]
        danmaku_lyrics.push
          time: time
          text: text
          sent: false
    danmaku.danmaku_lyrics = danmaku_lyrics
    if $('[data-route="default-index"]').length > 0
      $('#scrolldiv').scrollTop(0)
      $('.slimScrollBar').css('top', '0px')
