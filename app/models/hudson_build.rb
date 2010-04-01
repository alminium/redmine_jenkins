# $Id$

require 'hudson_api_error'
require 'hudson_exceptions'
require 'rexml_helper'
include RexmlHelper

class HudsonBuild < ActiveRecord::Base
  unloadable
  has_many :changesets, :class_name => 'HudsonBuildChangeset', :dependent => :destroy
  has_one :test_result, :class_name => 'HudsonBuildTestResult', :dependent => :destroy
  has_many :artifacts, :class_name => 'HudsonBuildArtifact', :dependent => :destroy
  belongs_to :job, :class_name => 'HudsonJob', :foreign_key => 'hudson_job_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'caused_by'

  # 空白を許さないもの
  validates_presence_of :hudson_job_id, :number

  # 重複を許さないもの
  validates_uniqueness_of :number, :scope => :hudson_job_id

  acts_as_event :title => Proc.new {|o| 
                                  retval = "#{l(:label_build)} #{o.job.name} #{o.number}: #{o.result}" unless o.building?
                                  retval = "#{l(:label_build)} #{o.job.name} #{o.number}: #{l(:notice_building)}" if o.building?
                                  retval
                                },
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
                             :find_options => {:include => {:job => :project}},
                             :permission => :view_hudson

  include HudsonHelper
  extend RexmlHelper

  def project
    return nil unless job
    return job.project
  end

  def event_url(options ={})
    return url_for(:user)
  end

  def url_for(type = :user)
    return "" unless self.job
    return "" unless self.job.settings
    return "" unless (self.job.name && self.job.name.length > 0)
    return "#{self.job.settings.url_for(type)}job/#{self.job.name}/#{self.number}"
  end

  def building?
    return true if "true" == self.building
    return false
  end

  def update_by_api(elem)
    return unless elem
    self.number = get_element_value(elem, "number")
    self.result = get_element_value(elem, "result")
    self.finished_at = Time.at(get_element_value(elem, "timestamp").to_f / 1000)
    self.building = get_element_value(elem, "building")
    self.caused_by = 1 # Redmine Admin
    self.error = ""
  end

  def update_by_rss(elem)
    info = HudsonBuild.parse_rss(elem)
    self.number = info[:number] unless self.number
    return unless info[:number].to_i == self.number
    self.result = info[:result]
    self.finished_at = info[:published]
    self.building = info[:building]
    self.caused_by = 1
    self.error = ""
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

  def add_artifact_from_xml(element)
    element.children.each do |child|
      next if child.is_a?(REXML::Text)
      next if "artifact" != child.name
      artifact = new_artifact(child)
      artifact.save
      self.artifacts << artifact
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
    retval.revision = get_revision_no(elem)
    return retval
  end

  def new_artifact(elem)
    retval = HudsonBuildArtifact.new
    retval.hudson_build_id = self.id
    retval.display_path = get_element_value(elem,"displayPath")
    retval.file_name = get_element_value(elem, "fileName")
    retval.relative_path = get_element_value(elem, "relativePath")
    return retval
  end

  def get_revision_no(elem)
    retval = get_element_value(elem, "revision")
    return retval if retval != ""
    retval = get_element_value(elem, "rev") # for mercurial or hudson 1.340
    return retval
  end

end

def HudsonBuild.count_of(job)
  return 0 unless job
  return 0 unless job.is_a?(HudsonJob)
  return HudsonBuild.count_by_sql(["select count(*) from #{HudsonBuild.table_name} where hudson_job_id = ?", job.id])
end

def HudsonBuild.parse_rss(entry)
  params = get_element_value(entry, "title").scan(/(.*)#(.*)\s\((.*)\)/)[0]
  retval = {}
  retval[:name] = params[0].strip
  retval[:number] = params[1]
  retval[:result] = params[2]
  retval[:url] = "#{entry.elements['link'].attributes['href']}"
  retval[:published] = Time.xmlschema(get_element_value(entry, "published")).localtime
  retval[:building] = "false"
  return retval
end

def HudsonBuild.exists_number?(job_id, number)

  return false unless job_id
  return false unless number

  return HudsonBuild.exists?(["#{HudsonBuild.table_name}.hudson_job_id = ? AND #{HudsonBuild.table_name}.number = ?", job_id, number])

end

def HudsonBuild.to_be_updated?(job_id, number)
  return !HudsonBuild.exists?(["#{HudsonBuild.table_name}.hudson_job_id = ? AND #{HudsonBuild.table_name}.number = ? AND #{HudsonBuild.table_name}.building = 'false'", job_id, number])
end

def HudsonBuild.find_by_changeset(changeset)
  return HudsonNoBuild.new() unless changeset
  retval = HudsonBuild.find(:all,
                            :order=>"#{HudsonBuild.table_name}.number",
                            :conditions=> ["#{HudsonBuildChangeset.table_name}.repository_id = ? and #{HudsonBuildChangeset.table_name}.revision = ?", changeset.repository.id, changeset.revision],
                            :joins=> "INNER JOIN #{HudsonBuildChangeset.table_name} ON #{HudsonBuildChangeset.table_name}.hudson_build_id = #{HudsonBuild.table_name}.id")
  return retval
end

class HudsonNoBuild
  attr_reader :hudson_job_id, :number, :error, :building, :url, :result, :artifacts

  def initialize
    @hudson_job_id = ""
    @number = ""
    @error = ""
    @building = ""
    @url = ""
    @result = ""
    @artifacts = []
  end

  def building?
    return false
  end

end
