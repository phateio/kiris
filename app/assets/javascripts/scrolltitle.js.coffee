class @Scrolltitle
  constructor: ->
    self = this
    self.title = ''
    self.last = ''
    self.speed = 1000
    self.suffix = '... '
    self.pos = 0

  start: =>
    self = this
    window.Scrolltitle_init_0 = false
    return if self.tid
    self.scrolling.call(self)
    self.tid = setInterval(->
      self.scrolling.call(self)
    , self.speed)

  stop: =>
    self = this
    return if not self.tid
    clearTimeout(self.tid)
    self.tid = false

  SIGTERM: =>
    self = this
    window.Scrolltitle_init_0 = true

  scrolling: =>
    self = this
    if self.last != document.title
      self.title = document.title
    if window.Scrolltitle_init_0
      document.title = self.title
      self.pos = 0
      self.stop()
      window.Scrolltitle_init_0 = false
      return
    loop
      document.title = (self.title.substr(self.pos) + self.suffix + self.title.substr(0, self.pos))
      self.pos++
      if self.pos > self.title.length
        self.pos = 0
      break unless self.title.length > 1 && self.last == document.title
    self.last = document.title
