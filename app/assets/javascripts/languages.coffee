# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.form form').on 'ajax:success', (event, data) ->
    container = $('.results')
    container.empty()
    if data.length > 0

      $.each data, (i, item) ->
        types = $.map item.type, (type) ->
          "<li class='type'>#{type}</li>"
        designers = $.map item.designers, (designer) ->
          "<li class='designer'>#{designer}</li>"

        container.append("<div class='item'>
          <div class='name'>#{item.name}</div>
          <span class='hits'>#{item.hits}</span>
            <ul class='types'>
              #{types.join('')}
            </ul>
            <ul class='designers'>
            #{designers.join('')}
            </ul>
        </div>")
    else
      container.append '<div class="warning">No data found</div>'

