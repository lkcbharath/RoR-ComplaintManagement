jQuery ->
  $(".js_inline_validate .js_validate_me").on 'blur', ->
  field = this
  field_name = this.id.replace('complaint_', '')
  field_value = $(field).val()
  url = $(field).closest('form').data('validateUrl') + '?' + field_name + '=' + field_value
  $.ajax url,
    type: 'POST'
    dataType: "json"
    success: (data, textStatus, jqXHR) ->
      field = $("." + 'js_complaint_' + data['field_name'])
      field_group = field.closest('.form-group')
      field.next('.help-block').remove()
      if data['valid']
        field_group.removeClass('has-error')
        field_group.addClass('success-block')
      else
        field_group.addClass('has-error')
        field_group.append("<span class='help-block'>" + data['message'] + "</span>")