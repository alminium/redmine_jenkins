# $Id$

class HudsonBuild < ActiveRecord::Base
  unloadable
  has_many :changesets, :class_name => 'HudsonBuildChangeset', :dependent => :destroy
  has_one :test_result, :class_name => 'HudsonBuildTestResult', :dependent => :destroy
  belongs_to :job, :class_name => 'HudsonJob', :foreign_key => 'hudson_job_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'caused_by'

  # 空白を許さないもの
  validates_presence_of :hudson_job_id, :number

  # 重複を許さないもの
  validates_uniqueness_of :number, :scope => :hudson_job_id

  acts_as_event :title => Proc.new {|o| "#{l(:label_build)} #{o.job.name} #{o.number}: #{o.result}"},
                :description => Proc.new{|o|
                                  items = []
                                  items << o.test_result.description_for_activity if o.test_result != nil
                                  items << HudsonBuildChangeset.description_for_activity(o.changesets) if o.changesets.length > 0
                                  items.join("; ")
                                },
                :datetime => :finished_at

  acts_as_activity_provider :type => 'hudson',
                             :timestamp => "#{HudsonBuild.table_name}.finished_at",
                             :author_key => "#{HudsonBuild.table_name}.caused_by",
                             :find_options => {:include => {:job => :project}}

  def initialize
    super
  end

  def project
    return "" unless job
    return job.project
  end

  def event_url
    return url
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
