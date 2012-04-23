window.AntCat or= {}

class AntCat.Panel

  constructor: ($element, @options = {}) ->
    @initialize $element

  initialize: ($element) =>
    @element = $element
      .addClass(@element_class)
      .mouseenter(=> @element.find('.icon').show() unless @is_editing())
      .mouseleave(=> @element.find('.icon').hide())
      .find('.icon.edit').click(@edit).end()
    @element.find('.icon').hide() unless AntCat.testing

  edit: =>
    return if @is_editing()

    $('.icon').hide() unless AntCat.testing
    @element.find('div.display').hide()
    @element.find('div.edit').show()

    @create_form @element.find('div.edit form'),
      on_done: @on_edit_done
      on_cancel: @on_edit_cancelled

    @setup_form()

    @options.on_edit_opened() if @options.on_edit_opened

    false

  on_edit_done: (panel_selector, new_content) =>
    $(panel_selector).replaceWith new_content
    @initialize $(panel_selector)

  on_edit_cancelled: =>
    @element.find('div.edit').hide()
    @element.find('div.display').show()

  setup_form: =>

  @is_editing: -> $(".#{@element_class} .antcat_form:first").is ':visible'
  is_editing: => @element.find('.antcat_form:first').is ':visible'
