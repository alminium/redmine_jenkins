# $Id$

class HudsonBuildChangeset < ActiveRecord::Base
  unloadable
  belongs_to :build, :class_name => 'HudsonBuild', :foreign_key => 'hudson_build_id'

  def description_for_activity
    return "r#{revision}"
  end

  def HudsonBuildChangeset.description_for_activity(changesets)
    return "" if changesets.length == 0
    revisions = []
    changesets.each{|changeset|revisions << changeset.description_for_activity}
    return "Changesets: #{revisions.join(', ')}"
  end

end
