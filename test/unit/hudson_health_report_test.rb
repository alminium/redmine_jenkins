# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonHealthReportTest < ActiveSupport::TestCase
  fixtures :hudson_jobs, :hudson_settings

  def test_get_health_report_url_should_be_return_zero_length_string

    target = HudsonHealthReport.new

    assert_equal "", target.get_health_report_url(nil)
    
    job_data = hudson_jobs(:have_white_space)
    job = HudsonJob.find(job_data.id)

    # target doesnot have job
    assert_equal "", target.get_health_report_url(job)

  end

  def test_update_by_xml

    xml = "<healthReport>"
    xml << "<description>Build stability: 最近の5個中、2個ビルドに失敗しました。</description>"
    xml << "<iconUrl>health-40to59.gif</iconUrl>"
    xml << "<score>59</score>"
    xml << "</healthReport>"

    doc = REXML::Document.new xml

    job_data = hudson_jobs(:have_white_space)
    job = HudsonJob.find(job_data.id)

    target = HudsonHealthReport.new
    target.job =job
    target.update_by_xml(doc.elements["//healthReport"])
    
    assert_equal "Build stability: 最近の5個中、2個ビルドに失敗しました。", target.description
    assert_equal 59, target.score
    assert_equal URI.escape("#{job.settings.url}job/#{job.name}/lastBuild/"), target.url

  end


end
