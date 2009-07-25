# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

class HudsonSettings < ActiveRecord::Base
  unloadable
  has_many :health_report_settings, :class_name => 'HudsonSettingsHealthReport', :dependent => :destroy

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

  # エラーメッセージに表示されるbegin, end を日本語名にするために追加。
  @@HUMANIZED_ATTRIBUTE_KEY_NAMES = {
    "health_report_settings" => l(:label_health_report_settings)
  }

  # attribute_key_name を人が分かる言葉にするためのメソッド。ActiveRecord がそもそも持っているものをカスタマイズ
  def HudsonSettings.human_attribute_name(attribute_key_name)
    @@HUMANIZED_ATTRIBUTE_KEY_NAMES[attribute_key_name] || super
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
