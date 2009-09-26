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

  include HudsonHelper
  include RexmlHelper

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

  def building?
    return true if "t" == self.building
    return false
  end

  def add_changesets_from_xml(element)
    element.children.each do |child|
      next if child.is_a?(REXML::Text)
      next if "changeSet" != child.name
      child.children.each do |item|
        next if item.is_a?(REXML::Text)
        next if "item" != item.name
        changeset = new_changeset(item)
        changeset.save
        self.changesets << changeset
      end
    end
  end

  def add_testresult_from_xml(element)
    test_result = nil
    element.children.each do |child|
      next if child.is_a?(REXML::Text)
      next if "action" != child.name
      next if "testReport" != get_element_value(child, "urlName")
      test_result = new_test_result(child)
      test_result.save
      self.test_result = test_result
      break
    end
  end

  def new_test_result(elem)
    retval = HudsonBuildTestResult.new
    retval.hudson_build_id = self.id
    retval.fail_count = get_element_value(elem, "failCount")
    retval.skip_count = get_element_value(elem, "skipCount")
    retval.total_count = get_element_value(elem, "totalCount")
    return retval
  end

  def new_changeset(elem)
    retval = HudsonBuildChangeset.new
    retval.hudson_build_id = self.id
    retval.repository_id = self.project.repository.id
    retval.revision = get_element_value(elem, "revision")
    return retval
  end

end

def HudsonBuild.exists?(job_id, number)

  return false unless job_id
  return false unless number

  return HudsonBuild.exists?(["#{HudsonBuild.table_name}.hudson_job_id = ? AND #{HudsonBuild.table_name}.number = ?", job_id, number])

end

class HudsonNoBuild
  attr_reader :hudson_job_id, :number, :error, :building, :url, :result

  def initialize
    @hudson_job_id = ""
    @number = ""
    @error = ""
    @building = ""
    @url = ""
    @result = ""
  end

  def building?
    return false
  end

end
