class @Danmaku
  constructor: ->
    self = this
    self.tid = 0
    self.last_id = 0
    self.count = 0
    self.size = null
    self.ajax = false
    self.server = 'danmaku.phate.io'

  connect: =>
    self = this

    if self.tid
      clearTimeout(self.tid)
      self.tid = false
    self.tid = setTimeout(->
      self.connect()
    , 120000)

    DEBUG('Danmaku: Hooking')
    self.ajax = $.ajax
      url: "//#{self.server}/poll"
      dataType: 'jsonp'
      global: false
      data:
        last_id: self.last_id
      success: (items, textStatus, jqXHR) ->
        loop
          break if self.ajax isnt jqXHR
          break if not memcache.get('danmaku')
          break if items.data.length == 0
          timestamp = items.data[0].timestamp
          for item in items.data
            delay = item.timestamp - timestamp
            if not (delay >= 0 && delay < 10000)
              delay = 0
            DEBUG("Danmaku: Received: #{item.text}, delay = #{delay}")
            self.create(item.text, item, delay)
            self.last_id = item.id
          break
        self.reconnect()
      error: ->
        self.reconnect()

  reconnect: =>
    self = this
    setTimeout (->
      self.connect()
    ), 1000

  create: (text, attributes = {}, delay = 0) =>
    self = this
    $container = $('#container')

    top = if attributes.top == undefined then Math.random() else attributes.top
    color = attributes.color || [255, 255, 255, 0.9]
    size = if self.size then self.size else (attributes.size || 1.0)
    weight = attributes.weight || 'bold'
    speed = attributes.speed || 1.0
    online = not attributes.offline
    uid = attributes.uid

    font_size = 24 * size
    font_weight = weight
    container_height = $container.height()
    span_top = (container_height - font_size) * top
    span_left = $(window).width()
    span_color = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, #{color[3]})"
    span_class = 'danmakuspan noselect'
    span_class += ' danmakuspan-offline' if not online

    if self.count <= 0
      self.count = 0
      scrolltitle.start()
    self.count++

    $span = $('<div/>',
      text: text
      class: span_class
    ).css(
      top: span_top
      left: span_left
      color: span_color
      'font-size': font_size
      'font-weight': font_weight
    ).data('uid', uid).appendTo($container)

    span_left_end = $span.width() * (-1)
    trajectory_length = parseInt($span.css('left'))

    $span.delay(delay).animate
      left: span_left_end
    ,
      duration: Math.floor(trajectory_length / 150 / speed * 1000) # 150px/s
      easing: 'linear'
      complete: ->
        self.count--
        scrolltitle.SIGTERM() if self.count < 1
        $span.remove()

  post: =>
    self = this

    $danmaku_input = $('#danmakubar form input')
    text = $.trim($danmaku_input.val())
    $danmaku_input.val('').trigger('blur')

    return if not text
    $.ajax
      url: "//#{self.server}/post"
      dataType: 'jsonp'
      data:
        text: text
      success: (items) ->
        if items.code != 200
          DEBUG("Danmaku: #{items.code} #{items.status}")
          self.create(text, offline: true)
        return if not memcache.get('danmaku')
        return if items.data.length == 0
        for item in items.data
          DEBUG('Danmaku: echo: ' + item.text)
          self.create(item.text, item)
      error: (items) ->
        DEBUG('Danmaku: ERROR: ' + items)
        self.create(text, offline: true)

  report: (target_uid) =>
    self = this
    $.ajax
      url: "//#{self.server}/report"
      dataType: 'jsonp'
      data:
        target_uid: target_uid

  clear: =>
    self = this
    $('.danmakuspan').trigger('click')
    self

  inputFocus: =>
    self = this
    $('#danmakubar form input').focus()
    self

  inputBlur: =>
    self = this
    $('#danmakubar form input').blur().val('')
    self

$(document).on 'click', '.danmakuspan', (event) ->
  $self = $(event.currentTarget)
  $self.fadeOut
    queue: false

$(document).on 'contextmenu', '.danmakuspan', (event) ->
  event.preventDefault()
  $self = $(event.currentTarget)
  target_uid = $self.data('uid')
  return if not target_uid
  option = confirm('Are you sure you want to report this danmaku as inappropriate?')
  return if option != true
  danmaku.report(target_uid)
  $self.trigger('click')

$(document).on 'ready', ->

  $(document).on 'submit', '#danmakubar form', (event) ->
    event.preventDefault()
    danmaku.post()

  $(document).keydown (event) ->
    KEY_ESC = 27
    KEY_ENTER = 13
    if event.which == KEY_ESC
      DEBUG('Keydown: ESC')
      event.preventDefault()
      danmaku.clear().inputBlur()
    else if event.which == KEY_ENTER && event.target.tagName != 'A' \
                                     && event.target.tagName != 'INPUT' \
                                     && event.target.tagName != 'BUTTON' \
                                     && event.target.tagName != 'TEXTAREA' \
                                     && event.target.tagName != 'SELECT'
      DEBUG('Keydown: ENTER')
      event.preventDefault()
      danmaku.inputFocus()
