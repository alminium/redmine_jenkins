# $Id$

require 'hudson_build'

class HudsonJob < ActiveRecord::Base
  unloadable
  belongs_to :project, :foreign_key => 'project_id'
  belongs_to :settings, :class_name => 'HudsonSettings', :foreign_key => 'hudson_id'

  attr_accessor :description
  attr_accessor :state

  attr_accessor :health_reports
  attr_accessor :builds

  include HudsonHelper
  include RexmlHelper

  # 空白を許さないもの
  validates_presence_of :project_id, :hudson_id, :name

  def initialize
    super
    initialize_added
  end

  def after_find
    initialize_added
  end

  def initialize_added
    @description = ""
    @state = ""
    @health_reports = []
    @builds = []
  end

  def url
    return "" unless self.settings
    return "#{self.settings.url}job/#{self.name}"
  end

  def latest_build
    return HudsonNoBuild.new if @builds.length == 0
    return @builds[0] if @builds.length > 0
  end

  def update_by_xml(element)
    self.description = get_element_value(element, "description")
    self.state = get_element_value(element, "color")
  end

  def update_health_report_by_xml(element)
    element.elements.each("healthReport") do |hReport|
      report = HudsonHealthReport.new(self, hReport)
      self.health_reports << report
    end
  end

end
