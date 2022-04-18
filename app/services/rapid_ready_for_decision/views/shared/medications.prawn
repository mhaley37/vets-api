@pdf.markup ERB.new(<<~HTML).result(binding)
  <p>
    <h3>Active Prescriptions</h3>
    <i>VHA records searched for medication prescriptions active as of <%= Time.zone.today.strftime('%m/%d/%Y') %></i> <br />
    <i>All VAMC locations using VistA/CAPRI were checked</i> <br />
  </p>

  <% if @assessed_data[:medications].present? %>
    <p> <br /> </p>
    <% @assessed_data[:medications].each do |medication| %>
      <p>
        <% if medication[:flagged] %>
          <font name="DejaVuSans">&#9654;</font>
          <b><%= medication['description'] %></b>
          <font name="DejaVuSans">&#9664;</font>
        <% else %>
          <b><%= medication['description'] %></b>
        <% end %>
        <br />
        Prescribed on: <%= medication['authoredOn'][0, 10].to_date.strftime('%m/%d/%Y') %> <br />
        <% if medication['dosageInstructions'].present? %>
          Dosage instructions: <%= medication['dosageInstructions'].join('; ') %><br />
        <% end %>
      </p>
    <% end %>
  <% else %>
    <p><br/></p>
    <h6>No active medications were found in the last year</h6>
  <% end %>

  <p> <br /> </p>
HTML
