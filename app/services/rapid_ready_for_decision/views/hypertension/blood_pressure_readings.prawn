@pdf.markup ERB.new(<<~HTML).result(binding)
  <%#
    Note: This templating language is HTML-inspired. It does not always behave like true HTML.
    To see limitations, check out the documentation: https://github.com/puzzle/prawn-markup.
  %>

  <p>
    <% if @assessed_data[:bp_readings].any? %>
      <h3>One Year of Blood Pressure History</h3>
    <% else %>
      <h3>No blood pressure records found</h3>
    <% end %>
  </p>

  <i>VHA records searched from <%= (@date - 1.year).strftime('%m/%d/%Y') %> to <%= @date.strftime('%m/%d/%Y') %></i> <br/>
  <i>All VAMC locations using VistA/CAPRI were checked</i>

  <% if @assessed_data[:bp_readings].any? %>
    <p>Blood pressure is shown as systolic/diastolic.</p>
  <% end %>

  <p> <br /> </p>

  <% @assessed_data[:bp_readings].each do |bp| %>
    <% systolic = bp[:systolic]['value'].round %>
    <% diastolic = bp[:diastolic]['value'].round %>

    <p>
      <b>Blood pressure: <%= systolic %>/<%= diastolic %></b> <br />
      Taken on: <%= bp[:effectiveDateTime].to_date.strftime('%m/%d/%Y') %>
        at <%= Time.iso8601(bp[:effectiveDateTime]).strftime('%H:%M %Z') %> <br />
      Location: <%= bp[:organization] || 'Unknown' %>
    </p>
  <% end %>

  <p> <br /> </p>
HTML
