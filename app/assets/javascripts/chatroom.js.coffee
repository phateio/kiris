class @Chat
  constructor: ->
    self = this
    self.tid = false
    self.xid = false
    self.lastid = -1
    self.session = ''

  connect: =>
    DEBUG('Chat: Hooking')
    self = this
    if self.tid
      clearTimeout self.tid
      self.tid = false
    self.tid = setTimeout (->
      self.connect()
    ), 120000
    self.xid = $.ajax
      url: '//127.0.0.1:8080/poll'
      dataType: 'jsonp'
      global: false
      data:
        session: self.session
        lastid: self.lastid
      success: (items) ->
        data = items.data
        for i of data
          item = data[i]
          if item.id != self.lastid + 1
            self.eventRestart()
          self.lastid = item.id
          switch item.type
            when 'names'
              self.eventNames(item)
            when 'join'
              self.eventJoin(item)
            when 'part'
              self.eventLeft(item)
            when 'quit'
              self.eventQuit(item)
            when 'kick'
              self.eventKick(item)
            when 'nick'
              self.eventRename(item)
            when 'action'
              self.eventAction(item)
            when 'message'
              self.eventMessage(item)
            else
              DEBUG('Chat: Undefined data "' + JSON.stringify(item) + '"')
        self.connect()
      error: ->
        setTimeout (->
          self.connect()
        ), 3000

  # Events
  eventRestart: () =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date()
    html = template.replace(/{{type}}/g, 'message msg_join')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(htmlspecialchars("System restarted")))
    $('#content>table').append(html)
    self.scrollDown()

  eventNames: (items) =>
    self = this
    data = items.nicks
    $('#onlinelist>ol').text('')
    for nick of data
      privilege = data[nick]
      $('#onlinelist>ol').append($('<li/>', {text: privilege + nick, 'data-nick': nick}))

  eventJoin: (item) =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date(item.timestamp)
    html = template.replace(/{{type}}/g, 'message msg_join')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(htmlspecialchars("#{item.nick} has joined")))
    $('#content>table').append(html)
    $('#onlinelist>ol').append($('<li/>', {text: item.nick, 'data-nick': item.nick}))
    self.scrollDown()

  eventLeft: (item) =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date(item.timestamp)
    html = template.replace(/{{type}}/g, 'message msg_left')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(htmlspecialchars("#{item.nick} has left (#{item.reason})")))
    $('#content>table').append(html)
    $("#onlinelist>ol [data-nick=#{item.nick}]").data('nick', '').slideUp().remove()
    self.scrollDown()

  eventQuit: (item) =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date(item.timestamp)
    html = template.replace(/{{type}}/g, 'message msg_quit')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(htmlspecialchars("#{item.nick} has quit (#{item.reason})")))
    $('#content>table').append(html)
    $("#onlinelist>ol [data-nick=#{item.nick}]").data('nick', '').slideUp().remove()
    self.scrollDown()

  eventKick: (item) =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date(item.timestamp)
    html = template.replace(/{{type}}/g, 'message msg_kick')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(htmlspecialchars("#{item.by} has kicked #{item.nick} (#{item.reason})")))
    $('#content>table').append(html)
    $("#onlinelist>ol [data-nick=#{item.nick}]").data('nick', '').slideUp().remove()
    self.scrollDown()

  eventRename: (item) =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date(item.timestamp)
    html = template.replace(/{{type}}/g, 'message msg_nick')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(htmlspecialchars("#{item.oldnick} is now known as #{item.newnick}")))
    $('#content>table').append(html)
    $("#onlinelist>ol [data-nick=#{item.oldnick}]").data('nick', item.newnick).text(item.newnick)
    self.scrollDown()

  eventMessage: (item) =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date(item.timestamp)
    html = template.replace(/{{type}}/g, 'message')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(self.wrapNick(htmlspecialchars(item.from), htmlspecialchars(item.text))))
    $('#content>table').append(html)
    self.scrollDown()

  eventAction: (item) =>
    self = this
    template = $.trim($('#chatroom-content-tr').html())
    timestamp = new Date(item.timestamp)
    html = template.replace(/{{type}}/g, 'action')
                   .replace(/{{datetime}}/g, getTimeString('Y-m-d H:i:s', timestamp))
                   .replace(/{{timestamp}}/g, getTimeString('H:i', timestamp))
                   .replace(/{{message}}/g, self.wrapColor(htmlspecialchars("#{item.from} #{item.text}")))
    $('#content>table').append(html)
    self.scrollDown()

  # Wrap functions
  wrapNick: (nickname, message) =>
    "<span class=\"nickname\">&lt;#{nickname}&gt;:</span> #{message}"

  wrapColor: (string) =>
    self = this
    string.replace(/\u000315/g, '<span class="color_light_gray">')
          .replace(/\u000314/g, '<span class="color_gray">')
          .replace(/\u000313/g, '<span class="color_pink">')
          .replace(/\u000312/g, '<span class="color_light_blue">')
          .replace(/\u000311/g, '<span class="color_light_cyan">')
          .replace(/\u000310/g, '<span class="color_teal">')
          .replace(/\u00030?9/g, '<span class="color_light_green">')
          .replace(/\u00030?8/g, '<span class="color_yellow">')
          .replace(/\u00030?7/g, '<span class="color_orange">')
          .replace(/\u00030?6/g, '<span class="color_purple">')
          .replace(/\u00030?5/g, '<span class="color_brown">')
          .replace(/\u00030?4/g, '<span class="color_red">')
          .replace(/\u00030?3/g, '<span class="color_green">')
          .replace(/\u00030?2/g, '<span class="color_blue">')
          .replace(/\u00030?1/g, '<span class="color_black">')
          .replace(/\u00030?0/g, '<span class="color_white">')

  # toolkits
  scrollDown: =>
    objDiv = document.getElementById('content')
    objDiv.scrollTop = objDiv.scrollHeight
