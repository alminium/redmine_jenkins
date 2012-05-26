# -*- coding: utf-8 -*-

class HudsonHealthReport < ActiveRecord::Base
  unloadable

  include HudsonHelper
  include RexmlHelper

  belongs_to :job, :class_name => 'HudsonJob', :foreign_key => 'hudson_job_id'

  def update_by_xml(element)
    self.description = get_element_value(element, "description")
    self.score = get_element_value(element, "score")
    self.url = self.get_health_report_url(self.job)
  end

  def get_health_report_url(job)
    return "" unless job
    return "" unless self.job
    return "" unless self.job.settings
    return "" unless self.job.settings.health_report_settings
    self.job.settings.health_report_settings.each do |hr_settings|
      if hr_settings.contained_in?(self.description)
        return URI.escape(hr_settings.get_url(job))
      end
    end
    return ""
  end

end
