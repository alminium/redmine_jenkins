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
    if self.description.index(job.settings.health_report_build_stability) != nil
      return URI.escape("#{job.settings.url}job/#{job.name}/lastBuild/")
    end
    if self.description.index(job.settings.health_report_test_result) != nil
      return URI.escape("#{job.settings.url}job/#{job.name}/lastBuild/testReport/")
    end
    return ""
  end

end
