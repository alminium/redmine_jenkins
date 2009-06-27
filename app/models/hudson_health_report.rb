# To change this template, choose Tools | Templates
# and open the template in the editor.

class HudsonHealthReport
  attr_accessor :description, :score, :url

  include HudsonHelper
  include RexmlHelper

  def initialize
    @description = ""
    @score = ""
    @url = ""
  end

  def initialize(job, element)
    self.description = get_element_value(element, "description")
    self.score = get_element_value(element, "score")
    self.url = get_health_report_url(job)
  end

  def get_health_report_url(job)
    if self.description.index("安定したビルド") != nil
      return URI.escape("#{job.settings.url}job/#{job.name}/lastBuild/")
    end
    if self.description.index("テスト結果") != nil
      return URI.escape("#{job.settings.url}job/#{job.name}/lastBuild/testReport/")
    end
    return ""
  end

end
