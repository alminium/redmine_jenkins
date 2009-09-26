/* $Id$ */

RevisionBuildResults = Class.create();
RevisionBuildResults.prototype = {
  initialize: function (revision) {
     this.revision = revision;
     this.results = $H();
  },
  add: function( result ) {
     this.results.set(result.job_name + result.number, result);
  }
}


