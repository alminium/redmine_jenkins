# $Id$

class HudsonJobSettings < ActiveRecord::Base
  unloadable

  belongs_to :job, :class_name => 'HudsonJob', :foreign_key => 'hudson_job_id'

  # 空白を許さないもの
  validates_presence_of :hudson_job_id

  include RexmlHelper
  include HudsonHelper

  def initialize(attributes = nil)
    super attributes
    self.build_rotate = false
    self.build_rotator_days_to_keep = -1
    self.build_rotator_num_to_keep = -1
  end

  def do_rotate?
    return false unless self.build_rotate
    return false unless (self.build_rotator_days_to_keep > 0 || self.build_rotator_num_to_keep > 0)
    return true
  end

  def fetch

    return unless self.job
    return unless self.job.settings

    api_uri = "#{job.config_url_for(:plugin)}"
    content = open_hudson_api(api_uri, self.job.settings.auth_user, self.job.settings.auth_password)

    doc = REXML::Document.new content

    self.update_by_xml(doc)

  end

  def update_by_xml(doc)
    return unless doc
    return unless doc.is_a?(REXML::Document)

    rotate = false
    days_to_keep = ""
    num_to_keep = ""
    doc.elements.each('//logRotator') do |log_rotator|
      rotate = true
      days_to_keep = get_element_value(log_rotator, 'daysToKeep')
      num_to_keep = get_element_value(log_rotator, 'numToKeep')
    end

    self.build_rotate = rotate
    self.build_rotator_days_to_keep = days_to_keep.to_i if days_to_keep =~ /^[+-]?\d+$/
    self.build_rotator_num_to_keep = num_to_keep.to_i if num_to_keep =~ /^[+-]?\d+$/

  end
  
end
