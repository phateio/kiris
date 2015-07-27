class InputHistory
  constructor: (options)->
    @storage = {}
    @storageKey = 'inputHistory'
    @options = options
    @h0 = if (s = @storage[@storageKey]) then s.split('\n') else [] # original history
    @h = @h0.concat(['']) # temporarily edited history
    @i = @h0.length # current index in history

  up: (event) ->
    $self = $(event.currentTarget)
    if @i > 0
      @h[@i--] = $self.val()
      $self.val @h[@i]
    @options.up(event) if @options.up

  down: (event) ->
    $self = $(event.currentTarget)
    if @i < @h0.length
      @h[@i++] = $self.val()
      $self.val @h[@i]
    @options.down(event) if @options.down

  enter: (event) ->
    $self = $(event.currentTarget)
    @options.before_enter(event) if @options.before_enter
    if @i < @h0.length
      @h[@i] = @h0[@i]
    input_value = $self.val()
    if @i >= 0 and @i >= @h0.length - 1 and @h0[@h0.length - 1] is input_value
      @h[@h0.length] = ''
    else
      @h[@h0.length] = input_value
      @h.push ''
      @h0.push input_value
      @storage[@storageKey] = @h0.join '\n'
    @i = @h0.length
    @options.after_enter(event) if @options.after_enter
    $self.val('')

$.fn.inputHistory = (options = {})->
  input_history = new InputHistory(options)
  @keydown (event) =>
    KEY_ENTER = 13
    KEY_UP = 38
    KEY_DOWN = 40
    switch event.which
      when KEY_UP then input_history.up(event)
      when KEY_DOWN then input_history.down(event)
      when KEY_ENTER then input_history.enter(event)
