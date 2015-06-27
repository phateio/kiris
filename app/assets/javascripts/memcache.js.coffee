class Memcache
  constructor: (options = {}) ->
    self = this
    if !window.localStorage
      window.localStorage = {}
    else
      for key, val of options
        self.set(key, val) if self.get(key) is undefined

  get: (key) =>
    raw = window.localStorage[key]
    return raw if raw is undefined
    try
      return JSON.parse(raw)
    catch error
      return undefined

  set: (key, val) =>
    raw = JSON.stringify(val)
    window.localStorage[key] = raw

@memcache = new Memcache
  lyrics: true
  danmaku: true
  background: true
  volume: 0.6
  muted: false

$(document).on 'change', '[data-option]', (event) ->
  $self = $(event.currentTarget)
  option = $self.data('option')
  type = $self.attr('type')
  switch type
    when 'checkbox'
      value = $self.is(':checked')
    else
      value = $self.val()
  memcache.set(option, value)

$(document).on 'memcache:restore', '[data-option]', (event) ->
  $self = $(event.currentTarget)
  option = $self.data('option')
  value = memcache.get(option)
  type = $self.attr('type')
  return if value is undefined
  switch type
    when 'checkbox'
      $self.prop('checked', value)
    else
      $self.val(value)
