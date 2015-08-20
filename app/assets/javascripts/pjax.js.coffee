@browserCompatibleDocumentParser = ->
  createDocumentUsingParser = (html) ->
    (new DOMParser).parseFromString html, 'text/html'

  createDocumentUsingDOM = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.documentElement.innerHTML = html
    doc

  createDocumentUsingWrite = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.open 'replace'
    doc.write html
    doc.close()
    doc

  # Use createDocumentUsingParser if DOMParser is defined and natively
  # supports 'text/html' parsing (Firefox 12+, IE 10)
  #
  # Use createDocumentUsingDOM if createDocumentUsingParser throws an exception
  # due to unsupported type 'text/html' (Firefox < 12, Opera)
  #
  # Use createDocumentUsingWrite if:
  #  - DOMParser isn't defined
  #  - createDocumentUsingParser returns null due to unsupported type 'text/html' (Chrome, Safari)
  #  - createDocumentUsingDOM doesn't create a valid HTML document (safeguarding against potential edge cases)
  try
    if window.DOMParser
      testDoc = createDocumentUsingParser '<html><body><p>test'
      createDocumentUsingParser
  catch e
    testDoc = createDocumentUsingDOM '<html><body><p>test'
    createDocumentUsingDOM
  finally
    unless testDoc?.body?.childNodes.length is 1
      return createDocumentUsingWrite

$.pjax = (url, history_method = 'replace') ->
  DEBUG("pjax: #{url}, #{history_method}")
  $link = $('#js-pjax-medium')
  if $link.length == 0
    $link = $('<a>', id: 'js-pjax-medium', class: 'hidden')
    $(document.body).append($link)
  $link.attr(href: url).data('history-method', history_method)
  $.rails.handleRemote($link)

$(document).on 'ajax:before', ->
  if window.pjax
    DEBUG('pjax.abort()')
    window.pjax.abort()
    window.pjax = null

$(document).on 'ajax:beforeSend', (event, xhr, settings) ->
  $self = $(event.target)
  xhr.setRequestHeader('Accept', 'text/html')
  xhr.setRequestHeader('X-XHR-Referer', document.location.href)
  xhr.url = settings.url  # .replace(/(?:\?_=[0-9]+$|_=[0-9]+&|&_=[0-9]+)/, '')
  history_method = $self.data('history-method')
  xhr.historyMethod = history_method if history_method
  settings.dataType = 'html'
  if settings.crossDomain
    window.open(xhr.url)
    return false
  window.pjax = xhr

$(document).on 'ajax:success', (event, data, status, xhr) ->
  DEBUG('ajax:success')

  new_location = xhr.getResponseHeader('X-XHR-Redirected-To')
  if new_location
    window.pjax = null if window.pjax == xhr
    $.pjax(new_location, 'push')
    return
  new_location = xhr.getResponseHeader('X-TOP-Redirected-To')
  if new_location
    document.location = new_location
    return
  return if not xhr.getResponseHeader('X-XHR-Route')

  createDocument = browserCompatibleDocumentParser()
  doc = createDocument(data)
  container = document.getElementById('pjax-container')
  new_container = doc.getElementById('pjax-container')
  container.parentNode.replaceChild(new_container, container)

  internal_style_sheet = document.getElementById('internal-style-sheet')
  new_internal_style_sheet = doc.getElementById('internal-style-sheet')
  internal_style_sheet.parentNode.replaceChild(new_internal_style_sheet, internal_style_sheet)

  meta_csrf_token = document.getElementsByName('csrf-token')[0]
  new_meta_csrf_token = doc.getElementsByName('csrf-token')[0]
  meta_csrf_token.parentNode.replaceChild(new_meta_csrf_token, meta_csrf_token)

  href = xhr.url
  title = doc.querySelector('title').textContent
  history_method = xhr.historyMethod
  window_location_href = window.location.href
  window_location_pathname = window.location.pathname
  DEBUG("old url: #{window_location_href}")
  DEBUG("old url: #{window_location_pathname}")
  DEBUG("new url: #{href}, #{history_method}")
  if window_location_href == href or window_location_pathname == href or history_method == 'replace'
    DEBUG("replaceState: #{href}")
    window.history.replaceState(pjax: true, title, href)
  else
    DEBUG("pushState: #{href}")
    window.history.pushState(pjax: true, title, href)
  document.title = title
  $('#scrolldiv').scrollTop(0)
  $('.slimScrollBar').css('top', '0px')

  window.pjax = null if window.pjax == xhr
  $(document).trigger('page:change')

  scripts = Array::slice.call new_container.querySelectorAll 'script:not([data-turbolinks-eval="false"])'
  for script in scripts when script.type in ['', 'text/javascript']
    copy = document.createElement 'script'
    copy.setAttribute(attr.name, attr.value) for attr in script.attributes
    copy.appendChild(document.createTextNode(script.innerHTML))
    { parentNode, nextSibling } = script
    parentNode.removeChild(script)
    parentNode.insertBefore(copy, nextSibling)

  ga('send', 'pageview')

$(document).on 'ajax:error', (event, xhr, status, error) ->
  DEBUG("ajax:error: #{error}")

$(window).on 'popstate', (event) ->
  state = event.originalEvent.state
  DEBUG('popstate: ' + JSON.stringify(state))
  href = window.location.href
  $.pjax(href)
