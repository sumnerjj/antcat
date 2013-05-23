$ -> new AntCat.ConvertToSubspeciesForm $('.convert_to_subspecies_form'), button_container: '> .fields_section .buttons_section'

class AntCat.ConvertToSubspeciesForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    new AntCat.NameField $('#new_species_id_field'), value_id: 'new_species_id', parent_form: @, species_only: true
    @element.bind 'keydown', (event) ->
      return false if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER
    super

  taxon_id: =>
    match = @form().attr('action').match /\d+/
    match and match[0]

  cancel: =>
    window.location = "/catalog/#{@taxon_id()}"
