$(document).on 'click', '#issuethread .js-link-etit, #issuereplies .js-link-etit', (event) ->
  $self = $(event.currentTarget)
  $outertext = $self.parents('.itemblock').find('.js-outertext')
  $editzone = $self.parents('.itemblock').find('.js-editzone')
  text = $outertext.text()
  $outertext.hide()
  $editzone.show()

$(document).on 'click', '#issuethread .js-link-open', (event) ->
  $self = $(event.currentTarget)
  $openezone = $self.parents('.itemblock').find('.js-openzone')
  $openezone.trigger('submit')

$(document).on 'click', '#issuethread .js-link-close', (event) ->
  $self = $(event.currentTarget)
  $closezone = $self.parents('.itemblock').find('.js-closezone')
  $closezone.trigger('submit')

$(document).on 'click', '#issuethread .js-link-delete, #issuereplies .js-link-delete', (event) ->
  $self = $(event.currentTarget)
  $deletezone = $self.parents('.itemblock').find('.js-deletezone')
  $deletezone.trigger('submit')

$(document).on 'click', '#issuethread .js-button-cancel, #issuereplies .js-button-cancel', (event) ->
  $self = $(event.currentTarget)
  $outertext = $self.parents('.itemblock').find('.js-outertext')
  $editzone = $self.parents('.itemblock').find('.js-editzone')
  $editzone.hide().trigger('reset')
  $outertext.show()
