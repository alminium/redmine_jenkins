# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonHealthReportTest < Test::Unit::TestCase
  fixtures :hudson_jobs, :hudson_settings

  def test_update_by_xml

    xml = "<healthReport>"
    xml << "<description>Build stability: 最近の5個中、2個ビルドに失敗しました。</description>"
    xml << "<iconUrl>health-40to59.gif</iconUrl>"
    xml << "<score>59</score>"
    xml << "</healthReport>"

    doc = REXML::Document.new xml

    job_data = hudson_jobs(:hasauth_threejob_twohealthreport_one)
    job = HudsonJob.find(job_data.id)

    target = HudsonHealthReport.new
    target.job =job
    target.update_by_xml(doc.elements["//healthReport"])
    
    assert_equal "Build stability: 最近の5個中、2個ビルドに失敗しました。", target.description
    assert_equal 59, target.score
    assert_equal URI.escape("#{job.settings.url}job/#{job.name}/lastBuild/"), target.url

  end


end
