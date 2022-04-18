@pdf.markup ERB.new(<<~HTML).result(binding)
  <%= @disability_type.capitalize %> Rapid Ready for Decision | Claim for Increase <br />
  <h1>
    VHA <%= @disability_type.capitalize %> Data Summary<br/>
  </h1>
  <i>Generated automatically on <%= @date.strftime('%m/%d/%Y') %> at <%= @date.strftime('%l:%M %p %Z') %></i>

  <p> <br /> </p>

  <%= RapidReadyForDecision::FastTrackPdfGenerator.extract_patient_name(@patient_info) %><br />

  <% if @patient_info[:birthdate] %>
    DOB: <%= @patient_info[:birthdate] %>
  <% end %>

  <p> <br /> </p>
HTML
