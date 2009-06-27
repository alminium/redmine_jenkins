# $Id$

class HudsonBuild < ActiveRecord::Base
  has_many :changesets, :class_name => 'HudsonBuildChangeset', :dependent => :destroy
  has_many :artifacts, :class_name => 'HudsonBuildArtifact', :dependent => :destroy
  belongs_to :job, :class_name => 'HudsonJob', :foreign_key => 'hudson_job_id'

  def initialize
    super
  end

  def url
    return "" unless job
    return "#{self.job.settings.url}job/#{self.job.name}/#{self.number}"
  end

end

class HudsonNoBuild
  def hudson_job_id
    return ""
  end
  def number
    return ""
  end
  def error
    return ""
  end
  def building
    return ""
  end
  def url
    return ""
  end
  def result
    return ""
  end
end
