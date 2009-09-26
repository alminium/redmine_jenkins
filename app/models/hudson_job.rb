# $Id$

require 'hudson_build'
require 'hudson_api_error'
require 'hudson_exceptions'

class HudsonJob < ActiveRecord::Base
  unloadable
  has_many :health_reports, :class_name => 'HudsonHealthReport', :dependent => :destroy
  belongs_to :project, :foreign_key => 'project_id'
  belongs_to :settings, :class_name => 'HudsonSettings', :foreign_key => 'hudson_id'

  attr_reader :hudson_api_errors

  # 空白を許さないもの
  validates_presence_of :project_id, :hudson_id, :name

  include HudsonHelper
  include RexmlHelper

  def initialize
    super
    initialize_added
  end

  def after_find
    initialize_added
  end

  def url
    return "" unless self.settings
    return "#{self.settings.url}job/#{self.name}"
  end

  def get_build(number)
    return HudsonNoBuild.new unless number
    return HudsonNoBuild.new if number.length == 0

    retval = HudsonBuild.find(:first, :conditions => ["#{HudsonBuild.table_name}.hudson_job_id = ? AND #{HudsonBuild.table_name}.number = ?",
                                                      self.id, number])
    retval = HudsonNoBuild.new unless retval
    return retval
  end

  def latest_build
    latest_build = get_build(self.latest_build_number)
    return latest_build
  end

  def destory_builds
    HudsonBuild.destroy_all(["#{HudsonBuild.table_name}.hudson_job_id = ?", self.id])
  end

  def update_by_xml(element)
    self.description = get_element_value(element, "description")
    self.state = get_element_value(element, "color")
    latest_build_info = element.elements["lastBuild"]
    self.latest_build_number = get_element_value(latest_build_info, "number") if latest_build_info
  end

  def update_health_report_by_xml(element)
    hr_index = 0
    element.elements.each("healthReport") do |hReport|
      report = nil
      if hr_index < self.health_reports.length
        report = self.health_reports[hr_index]
      end

      unless report
        report = HudsonHealthReport.new
        report.job = self
        report.hudson_job_id = self.id
        self.health_reports << report
      end

      report.update_by_xml(hReport)
      report.save

      hr_index += 1
    end
  end

  def request_build
    clear_hudson_api_errors
    api_url = "#{self.settings.url}job/#{self.name}/build"
    open_hudson_api(api_url, self.settings.auth_user, self.settings.auth_password)
  rescue HudsonApiException => error
    @hudson_api_errors << HudsonApiError.new(self.class.name, "request_build", error)
  end

  def fetch_recent_builds
    clear_hudson_api_errors
    api_uri = "#{self.settings.url}job/#{self.name}/rssAll"
    content = open_hudson_api(api_uri, self.settings.auth_user, self.settings.auth_password)

    doc = REXML::Document.new content
    retval = []
    doc.elements.each("//entry") do |entry|
      buildinfo = parse_rss_build(entry)
      retval << buildinfo
    end
    return retval
  rescue HudsonApiException => error
    @hudson_api_errors << HudsonApiError.new(self.class.name, "fetch_recent_builds", error)
  end

  def fetch_builds
    clear_hudson_api_errors
    return unless do_fetch?
    fetch_summary
    fetch_detail if self.settings.get_build_details
  rescue HudsonApiException => error
    @hudson_api_errors << HudsonApiError.new(self.class.name, "fetch_builds", error)
  end

private
  def initialize_added
    @hudson_api_errors = []
  end

  def clear_hudson_api_errors
    @hudson_api_errors = []
  end

  def fetch_summary
    api_url = "#{self.settings.url}job/#{self.name}/rssAll"
    begin
      content = open_hudson_api(api_url, self.settings.auth_user, self.settings.auth_password)
    rescue HudsonApiException => error
      raise error
    end

    doc = REXML::Document.new content
    doc.elements.each("//entry") do |entry|
      buildinfo = parse_rss_build(entry)
      build = get_build(buildinfo[:number])
      next if build.is_a? HudsonBuild and false == build.building?
      build = update_build(build, buildinfo) if build.is_a? HudsonBuild and build.building?
      build = new_build(buildinfo) if build.is_a? HudsonNoBuild
      build.save
    end

    latest_build = get_build(self.latest_build_number)

    add_latest_build if latest_build.is_a? HudsonNoBuild
  end

  def fetch_detail

    api_url = "#{self.settings.url}job/#{self.name}/api/xml?depth=1"
    api_url << "&exclude=//build/changeSet/item/path"
    api_url << "&exclude=//build/changeSet/item/addedPath"
    api_url << "&exclude=//build/changeSet/item/modifiedPath"
    api_url << "&exclude=//build/changeSet/item/deletedPath"
    api_url << "&exclude=//build/culprit"
    api_url << "&exclude=//module"
    api_url << "&exclude=//firstBuild&exclude=//lastBuild"
    api_url << "&exclude=//lastCompletedBuild"
    api_url << "&exclude=//lastFailedBuild"
    api_url << "&exclude=//lastStableBuild"
    api_url << "&exclude=//lastSuccessfulBuild"
    content = ""
    begin
      content = open_hudson_api(api_url, self.settings.auth_user, self.settings.auth_password)
    rescue HudsonApiException => error
      raise error
    end

    begin
      doc = REXML::Document.new content
    rescue REXML::ParseException => error
      raise HudsonApiException.new(error)
    end

    doc.elements.each("//build") do |buildelem|
      build_number = get_element_value(buildelem, "number")
      build = get_build(build_number)
      next unless build

      if build.is_a?(HudsonNoBuild)
        buildinfo = parse_xml_build(buildelem)
        build = new_build(buildinfo)
        build.save
      end

      # チェンジセットを取得する
      build.add_changesets_from_xml buildelem if self.project.repository != nil

      # テスト結果を取得する
      build.add_testresult_from_xml buildelem

    end
    
  end

  def do_fetch?
    latest_build = get_build(self.latest_build_number)
    return true if latest_build.is_a? HudsonNoBuild
    return true if latest_build.building?
    
    return false
  end

  def new_build(buildinfo)
    retval = HudsonBuild.new()
    retval.hudson_job_id = self.id
    retval.number = buildinfo[:number]
    retval.result = buildinfo[:result]
    retval.finished_at = buildinfo[:published]
    retval.building = buildinfo[:building]
    retval.caused_by = 1 # デフォルトのAdminを想定している
    retval.error = ""
    return retval
  end

  def update_build(build, buildinfo)
    build.result = buildinfo[:result]
    build.finished_at = buildinfo[:published]
    build.building = buildinfo[:building]
    build.caused_by = 1 # デフォルトのAdminを想定している
    build.error = ""
    return build
  end

  def add_latest_build
    buildinfo = {}
    buildinfo[:number] = self.latest_build_number
    buildinfo[:result] = ""
    buildinfo[:published] = ""
    buildinfo[:building] = true

    build = new_build(buildinfo)
    build.save
  end

end

class HudsonNoJob
  attr_reader :id, :project_id, :hudson_id, :name, :latest_build_number, :created_at, :updated_at, :description, :state

  def initialize
    @id = ""
    @project_id = ""
    @name = ""
    @latest_build_number = ""
    @created_at = ""
    @updated_at = ""
    @description = ""
    @state = ""
  end

end

