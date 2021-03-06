$('#essence_picture_<%= @content_id -%>').remove()

<% if max_image_count.present? && @essence_pictures.length < max_image_count.to_i %>
$picture_editor = $('#element_<%= @element.id -%>_contents')
if $('div.add_content', $picture_editor).length == 0
  $('#element_<%= @element.id -%>_contents').append('<%= escape_javascript(
    render(
      :partial => "alchemy/admin/elements/add_content",
      :locals => {
        :element => @element,
        :options => @options
      }
    )
  ) %>')
<% end %>

Alchemy.SortableContents '#element_<%= @element.id -%>_contents', '<%= form_authenticity_token -%>'
Alchemy.reloadPreview()
Alchemy.pleaseWaitOverlay(false)
