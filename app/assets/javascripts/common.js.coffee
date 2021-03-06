String::strip = ->
  @replace(/^\s+|\s+$/g, '')

@DEBUG = () ->
  if not @debug
    return
  parameters = Array.prototype.slice.call(arguments)
  parameters[0] = "%s [DEBUG] #{parameters[0]}"
  parameters.splice(1, 0, getTimeString('Y-m-d H:i:s'))
  console.log.apply(console, parameters)

@htmlspecialchars = (text) ->
  text.replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")

@getTimeString = (format, datetime = (new Date())) ->
  Year   = datetime.getFullYear()
  Month  = datetime.getMonth() + 1
  Day    = datetime.getDate()
  Hour   = datetime.getHours()
  Minute = datetime.getMinutes()
  Second = datetime.getSeconds()
  format.replace('Y', Year)
        .replace('m', ('0' + Month).substr(-2))
        .replace('n', Month)
        .replace('d', ('0' + Day).substr(-2))
        .replace('j', Day)
        .replace('H', ('0' + Hour).substr(-2))
        .replace('i', ('0' + Minute).substr(-2))
        .replace('s', ('0' + Second).substr(-2))

@getSelected = ->
  return window.getSelection() if window.getSelection
  return document.getSelection() if document.getSelection
  return document.selection.createRange().text if document.selection

@rand = (min, max) ->
  Math.floor(Math.random() * (max - min + 1) + min)

@unix_timestamp = ->
  Math.floor($.now() / 1000)

@is_mobile = ->
  /Mobile/i.test(navigator.userAgent)

@is_touch_device = ->
  'ontouchstart' in window || 'onmsgesturechange' in window

$(document).ajaxStart ->
  NProgress.start()
  $(document.body).addClass('progress')
$(document).ajaxStop ->
  NProgress.done()
  $(document.body).removeClass('progress')

$(window).on 'resize', ->
  $window = $(window)
  $('#playing li[id]').trigger('playlist:resize')
  $('[data-flexible-table]').each (index) ->
    $this = $(this)
    window_width = $window.width()
    subpage_padding = 18*2
    inside_padding = 12*8
    object_width = window_width - subpage_padding - inside_padding
    $this.find('tr:first-child td:not([data-flexible-width])').each (index) ->
      $header_td = $(this)
      object_width -= $header_td.outerWidth()
    $this.find('tr:first-child td[data-flexible-width]').each (index) ->
      $header_td = $(this)
      column_index = $header_td.index() + 1
      column_scale = parseFloat($header_td.data('flexible-width')) * 0.01
      $this.find("tr td:nth-child(#{column_index})").each (index) ->
        $body_td = $(this)
        $body_td.css('max-width', object_width * column_scale)

$(window).on 'page:refresh', (event, options = {}) ->
  window.updated_at = unix_timestamp()
  settings =
    url: '/status.json'
    dataType: 'json'
    cache: false
    global: false
    timeout: 60000
    success: (data) ->
      listeners = parseInt(data['listeners'])
      $('#listeners').append("<li>#{listeners}</li>")
      $('#listeners>li:not(:last-child)').slideUp 1000, ->
        $(this).remove()
  $.extend(settings, options)
  $.ajax(settings)

$(document).on 'page:change', ->
  $(window).trigger('resize')
  $('[data-option]').trigger('memcache:restore')
  $('#tooltips').hide()

$(document).on 'mouseenter', '[data-tooltips-text]', (event) ->
  $self = $(event.currentTarget)
  $tooltips = $('#tooltips')

  text = $self.data('tooltips-text')
  direction = $self.data('tooltips-direction') || 'left'
  padding = $self.data('tooltips-padding')
  padding = parseInt(padding) || 24

  return if text is undefined

  text = 'N/A' if not text
  offset = $self.offset()

  switch direction.toLowerCase()
    when 'top'
      x = offset.left + Math.abs($self.width() / 2 - $tooltips.width() / 2) - 6 # #tooltips padding-left
      y = offset.top + $tooltips.height() + padding
      $tooltips.addClass('arrow-top')
               .removeClass('arrow-bottom')
               .removeClass('arrow-left')
               .removeClass('arrow-right')
    when 'bottom'
      x = offset.left + Math.abs($self.width() / 2 - $tooltips.width() / 2) - 6 # #tooltips padding-left
      y = offset.top - $tooltips.height() - padding
      $tooltips.addClass('arrow-bottom')
               .removeClass('arrow-top')
               .removeClass('arrow-left')
               .removeClass('arrow-right')
    when 'left'
      x = offset.left + $self.width() + padding
      y = offset.top
      $tooltips.addClass('arrow-left')
               .removeClass('arrow-top')
               .removeClass('arrow-bottom')
               .removeClass('arrow-right')
    when 'right'
      x = offset.left - $tooltips.width() - padding
      y = offset.top
      $tooltips.addClass('arrow-right')
               .removeClass('arrow-top')
               .removeClass('arrow-bottom')
               .removeClass('arrow-left')

  window.tooltips_src = $self.get(0)
  $tooltips.text(text).css(
    top: y
    left: x
  ).show()
.on 'mouseover', '[data-tooltips-text]', (event) ->
  if window.tooltips_tid
    clearTimeout(window.tooltips_tid)
    window.tooltips_tid = false
.on 'mouseout', '[data-tooltips-text]', (event) ->
  $tooltips = $('#tooltips')
  if not window.tooltips_tid && $tooltips.is(':visible')
    window.tooltips_tid = setTimeout(->
      $tooltips.hide()
    , 800)

$(document).on 'mouseenter', '#tooltips', (event) ->
  if window.tooltips_tid
    clearTimeout(window.tooltips_tid)
    window.tooltips_tid = false
.on 'mouseleave', '#tooltips', (event) ->
  self = this
  window.tooltips_tid = setTimeout(->
    $(self).hide()
  , 800)

$(document).on 'click', (event) ->
  $self = $(event.currentTarget)
  $all_sub_menu = $('.sub-menu')
  DEBUG('.sub-menu all hidden')
  $all_sub_menu.addClass('hidden')

$(document).on 'click', '.js-dropdown-menu>li>a', (event) ->
  $self = $(event.currentTarget)
  $sub_menu = $self.parent().find('.sub-menu')
  $all_sub_menu = $('.sub-menu')
  $all_sub_menu.not($sub_menu).addClass('hidden')
  DEBUG('.sub-menu all hidden except currentTarget')
  $sub_menu.toggleClass('hidden')
  return false

$(document).on 'click', '.js-dropdown-menu .sub-menu a', (event) ->
  $self = $(event.currentTarget)
  $sub_menu = $self.parents('.sub-menu')
  $sub_menu.addClass('hidden')

$(document).on 'click', '.js-button-hide', (event) ->
  $self = $(event.currentTarget)
  $level = parseInt($self.data('parent-level')) || 1
  $target = $self
  $target = $target.parent() for [1..$level]
  $target.hide()

$(document).on 'click', '.js-button-fadeOut', (event) ->
  $self = $(event.currentTarget)
  $level = parseInt($self.data('parent-level')) || 1
  $target = $self
  $target = $target.parent() for [1..$level]
  $target.fadeOut()

$(document).on 'click', '.js-button-delete', (event) ->
  $self = $(event.currentTarget)
  $level = parseInt($self.data('parent-level')) || 1
  $target = $self
  $target = $target.parent() for [1..$level]
  $target.remove()

$(document).on 'click', '.js-flatedit', (event) ->
  $self = $(event.currentTarget)
  $self.removeClass('flatblock')

$(document).on 'focusout', '.js-flatedit', (event) ->
  $self = $(event.currentTarget)
  $self.addClass('flatblock')

$(document).on 'keydown', '.js-flatedit', (event) ->
  $self = $(event.currentTarget)
  KEY_ENTER = 13
  KEY_ESC = 27
  if event.which == KEY_ENTER
    DEBUG('.js-flatedit Keydown: ENTER')
    event.preventDefault()
    $self.blur()
  else if event.which == KEY_ESC
    DEBUG('.js-flatedit Keydown: ESC')
    event.preventDefault()
    $self.blur()

$(document).keydown (event) ->
  KEY_ESC = 27
  KEY_L = 76
  return if event.target.tagName in [
    'A',
    'INPUT',
    'BUTTON',
    'TEXTAREA',
    'SELECT'
  ]
  if event.which == KEY_ESC
    DEBUG('Global Keydown: ESC')
    event.preventDefault()
    if window.pjax
      window.pjax.abort()
      window.pjax = null
  else if event.altKey && event.which == KEY_L
    DEBUG('Global Keydown: ALT + L')
    $.pjax('/login', 'push') if window.history.pushState

$(document).ready ->
  window.timer = new Timer()
  window.danmaku = new Danmaku()
  window.scrolltitle = new Scrolltitle()
  NProgress.configure(showSpinner: false)

  window.timer.callback = ->
    setTimeout ->
      window.timer.refresh()
      $(window).trigger('page:refresh')
    , rand(5, 30) * 1000
  window.timer.start()

  setInterval ->
    pasttime = unix_timestamp() - window.updated_at
    timeleft = timer.nexttime - unix_timestamp()
    $(window).trigger('page:refresh') if pasttime > 30 && timeleft > 30
  , 60000
  $(window).trigger('page:refresh')

$(window).load ->
  if $('#backimg_front').length != 0
    setTimeout ->
      window.danmaku.connect()
    , 3000
    $(document).trigger('page:change')

  unless memcache.get('intro')
    intro = introJs()
    intro.setOptions
      showStepNumbers: false
      showBullets: true
    intro.start()
    memcache.set('intro', new Date())
