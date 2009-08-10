/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
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


