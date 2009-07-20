# To change this template, choose Tools | Templates
# and open the template in the editor.

class HudsonHealthReport
  unloadable
  attr_accessor :job, :description, :score, :url

  include HudsonHelper
  include RexmlHelper

  def initialize
    @description = ""
    @score = ""
    @url = ""
    @job = nil
  end

  def initialize(job, element)
    self.job = job
    self.description = get_element_value(element, "description")
    self.score = get_element_value(element, "score")
    self.url = get_health_report_url(job)
  end

  def get_health_report_url(job)
    job.settings.health_report_settings.each do |hr_settings|
      if hr_settings.contained_in?(self.description)
        return URI.escape(hr_settings.get_url(job))
      end
    end
    return ""
  end

end
