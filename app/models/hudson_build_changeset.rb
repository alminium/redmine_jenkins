# $Id$

class HudsonBuildChangeset < ActiveRecord::Base
  unloadable
  belongs_to :build, :class_name => 'HudsonBuild', :foreign_key => 'hudson_build_id'

  # 空白を許さないもの
  validates_presence_of :hudson_build_id, :revision

  def description_for_activity
    return "" unless (revision and revision.length > 0)
    return "r#{revision}"
  end

end

def HudsonBuildChangeset.description_for_activity(changesets)
  return "" if changesets.length == 0
  revisions = []
  changesets.each{|changeset|revisions << changeset.description_for_activity}
  return "Changesets: #{revisions.join(', ')}"
end
