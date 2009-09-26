/* $Id$ */

BuildResult = Class.create();
BuildResult.prototype = {
  initialize: function (job_name, number, result, finished_at, finished_at_tag, url) {
     this.job_name = job_name;
     this.number = number;
     this.result = result;
     this.finished_at = finished_at;
     this.finished_at_tag = finished_at_tag;
     this.url = url;
  },
  message: function() {
      retval = ""
      retval += "<span class='result " + this.result.toLowerCase() + "' style='font-weight:bold;'>" + this.result + "</span>";
      retval += " built by <a href='" + this.url + "'>" + this.job_name + " #" + this.number + "</a>";
      retval += " at " + this.finished_at_tag + " ago";
      return retval;
  }
}

