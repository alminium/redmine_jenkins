# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonSettingsHealthReportTest < Test::Unit::TestCase
  fixtures :hudson_settings_health_reports, :hudson_settings, :hudson_jobs
  set_fixture_class :hudson_settings => HudsonSettings

  def test_containd_in_should_be_true
    data = hudson_settings_health_reports(:hasauth_threejob_twohealthreport_build_stability)
    target = HudsonSettingsHealthReport.find(data.id)
    
    assert_equal true, target.contained_in?("test message #{data.keyword} --" )
  end

  def test_containd_in_should_be_false
    data = hudson_settings_health_reports(:hasauth_threejob_twohealthreport_build_stability)
    target = HudsonSettingsHealthReport.find(data.id)

    assert_equal false, target.contained_in?("test message" )
  end

  def test_get_url
    data = hudson_settings_health_reports(:hasauth_threejob_twohealthreport_build_stability)
    target = HudsonSettingsHealthReport.find(data.id)

    data_job = hudson_jobs(:hasauth_threejob_twohealthreport_one)
    job = HudsonJob.find(data_job.id)

    settings = hudson_settings(:hasauth_threejob_twohealthreport)

    url = settings.url + "job/#{job.name}/lastBuild/"
    assert_equal url, target.get_url(job)
  end

  def test_is_blank_should_be_true
    hash = {}
    assert_equal true, HudsonSettingsHealthReport.is_blank?(hash)
    hash[:keyword] = ""
    hash[:url_format] = ""
    assert_equal true, HudsonSettingsHealthReport.is_blank?(hash)
  end

  def test_is_blank_should_be_false
    hash = {}
    hash[:keyword] = "aa"
    assert_equal false, HudsonSettingsHealthReport.is_blank?(hash)
    hash[:url_format] = "bb"
    assert_equal false, HudsonSettingsHealthReport.is_blank?(hash)
  end

  def test_update_from_hash
    hash = {}
    data = hudson_settings_health_reports(:hasauth_threejob_twohealthreport_build_stability)
    hash[:keyword] = data.keyword
    hash[:url_format] = data.url_format
    target = HudsonSettingsHealthReport.new
    target.update_from_hash hash
    assert_equal data.keyword, target.keyword
    assert_equal data.url_format, target.url_format
  end

  def test_update_from_hash_nil
    hash = {}
    target = HudsonSettingsHealthReport.new
    target.update_from_hash hash
    assert_equal nil, target.keyword
    assert_equal nil, target.url_format
  end

  def test_update_from_hash_zerolength
    hash = {}
    hash[:keyword] = ""
    hash[:url_format] = ""
    target = HudsonSettingsHealthReport.new
    target.update_from_hash hash
    assert_equal "", target.keyword
    assert_equal "", target.url_format
  end

end
