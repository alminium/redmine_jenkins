# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "digest/sha1"

class HudsonSettings < ActiveRecord::Base
  # 空白を許さないもの
  validates_presence_of :project_id, :url

  # 重複を許さないもの
  validates_uniqueness_of :project_id

  DELIMITER = ','

  def is_new?
    return true if self.project_id == nil
    return false
  end

  def job_include?(other)
    return false if self.job_filter == nil
    value = HudsonSettings.to_array( self.job_filter )
    return value.include?(other.to_s)
  end

end

def HudsonSettings.load(project)
  retval = HudsonSettings.find(:first,  :conditions => "project_id = #{project.id}") if project != nil
  retval = HudsonSettings.new() if retval == nil
  return retval
end

def HudsonSettings.to_array(value)
  return [] if value == nil
  return value.split(HudsonSettings::DELIMITER)
end

def HudsonSettings.to_value(value)
  return "" if value == nil
  return value.join(HudsonSettings::DELIMITER)
end
