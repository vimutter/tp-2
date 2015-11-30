# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.form form').on 'ajax:success', (event, data) ->
    if data.length > 0
      container = $('.results')
      container.empty()

      $.each data, (i, item) ->
        types = $.map item.type, (type) ->
          "<li class='type'>#{type}</li>"
        designers = $.map item.designers, (designer) ->
          "<li class='designer'>#{designer}</li>"

        container.append("<div class='item'>
          <div class='name'>#{item.name}</div>
            <ul>
              #{types.join('')}
            </ul>
            <ul>
            #{designers.join('')}
            </ul>
        </div>")
    else

