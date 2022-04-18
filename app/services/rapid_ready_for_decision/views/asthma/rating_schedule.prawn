@pdf.markup ERB.new(<<~HTML).result(binding)
  <%#
    Note: This templating language is HTML-inspired. It does not always behave like true HTML.
    To see limitations, check out the documentation: https://github.com/puzzle/prawn-markup.
  %>

  <h3>Asthma Rating Schedule</h3>

  <table>
    <tr>
      <td>100%</td>
      <td>
        FEV-1 less than 40-percent predicted, or;<br/>
        FEV-1/FVC less than 40 percent, or;<br/>
        more than one attack per week with episodes of respiratory failure, or;<br/>
        requires daily use of systemic (oral or parenteral) high dose corticosteroids <br/>
        or immuno-suppressive medications
      </td>
    </tr>
    <tr>
      <td><color rgb="ffffff">_</color> 60%</td>
      <td>
        FEV-1 of 40- to 55-percent predicted, or;<br/>
        FEV-1/FVC of 40 to 55 percent, or;<br/>
        at least monthly visits to a physician for required care of exacerbations, or;<br/>
        intermittent (at least three per year) courses of systemic (oral or parenteral) corticosteroids
      </td>
    </tr>
    <tr>
      <td><color rgb="ffffff">_</color> 30%</td>
      <td>
        FEV-1 of 56- to 70-percent predicted, or;<br/>
        FEV-1/FVC of 56 to 70 percent, or;<br/>
        daily inhalational or oral bronchodilator therapy, or;<br/>
        inhalational anti-inflammatory medication
      </td>
    </tr>
    <tr>
      <td><color rgb="ffffff">_</color> 10%</td>
      <td>
        EV-1 of 71- to 80-percent predicted, or;<br/>
        FEV-1/FVC of 71 to 80 percent, or;<br/>
        intermittent inhalational or oral bronchodilator therapy
      </td>
    </tr>
  </table>

  <p>
    <b>Note:</b>
    In the absence of clinical findings of asthma at time of examination, a verified history of asthmatic attacks must be of record.
    <a href="https://www.ecfr.gov/current/title-38/chapter-I/part-4/subpart-B/subject-group-ECFR14fb86bcc86c2cb/section-4.97">
      <color rgb="0000ff">View rating schedule</color>
    </a>
  </p><br/>

  <p><br/></p>
HTML
