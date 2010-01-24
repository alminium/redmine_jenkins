# $Id$

class HudsonJobSettings < ActiveRecord::Base
  unloadable

  belongs_to :job, :class_name => 'HudsonJob', :foreign_key => 'hudson_job_id'

  # 空白を許さないもの
  validates_presence_of :hudson_job_id

  include RexmlHelper
  extend HudsonHelper

  def initialize(attributes = nil)
    super attributes
    @build_rotate = false
    @build_rotator_days_to_keep = -1
    @build_rotator_num_to_keep = -1
  end

  def do_rotate?
    return false unless self.build_rotate
    return false unless (self.build_rotator_days_to_keep > 0 || self.build_rotator_num_to_keep > 0)
    return true
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

def HudsonJobSettings.fetch(settings, job_name)

  raise Exception.new("Argument invalid settings isn't HudsonSettings") unless settings.is_a? HudsonSettings

  api_uri = "#{settings.url}job/#{job_name}/config.xml"

  content = open_hudson_api(api_uri, settings.auth_user, settings.auth_password)

  doc = REXML::Document.new content

  retval = HudsonJobSettings.new
  retval.update_by_xml(doc)

  return retval

end
