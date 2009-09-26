/* $Id$ */

HealthReportFieldAppender = Class.create();
HealthReportFieldAppender.prototype = {
  initialize: function (message, initial_count) {
    this.healthReportFieldCount = initial_count;
    this.message = message;
  },
  add:  function()  {
    if (this.healthReportFieldCount >= 10) return false
    this.healthReportFieldCount++;

    var k = "<input type='text' name='" + "new_health_report_settings[" + this.healthReportFieldCount + "][keyword]" + "' size=20>";
    var u = "<input type='text' name='" + "new_health_report_settings[" + this.healthReportFieldCount + "][url_format]" + "' size=60>";

    fs = document.getElementById("health_report_fields");
    p = fs.appendChild(document.createElement("p"));
    msg = document.createElement("span");
    var innerHTML = this.message;
    innerHTML = innerHTML.replace("${keyword}", k);
    innerHTML = innerHTML.replace("${url_format}", u);
    msg.innerHTML = innerHTML;
    p.appendChild(msg);
    return true;
  }
}
