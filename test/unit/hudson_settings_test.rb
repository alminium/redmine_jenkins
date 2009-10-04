# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonSettingsTest < Test::Unit::TestCase
  fixtures :hudson_settings, :hudson_settings_health_reports
  set_fixture_class :hudson_settings => HudsonSettings

  def test_job_include_should_be_false
    mydata = hudson_settings(:noauth_onejob_nohealthreport)
    target = HudsonSettings.find( mydata.id )
    assert_equal false, target.job_include?(mydata.job_filter + "--")
  end

  def test_add_last_slash_to_url_should_add
    url = ""
    target = HudsonSettings.add_last_slash_to_url(url)
    assert_equal "/", target
  end

  def test_add_last_slash_to_url_should_not_add
    url = "test/"
    target = HudsonSettings.add_last_slash_to_url(url)
    assert_equal "test/", target
  end

  def test_hasauth_twojob_twohealthreport
    mydata = hudson_settings(:hasauth_threejob_twohealthreport)
    target = HudsonSettings.find_by_project_id( mydata.project_id )

    assert_equal true, target.use_authentication?
    assert_equal 2, target.health_report_settings.length

    mydata.job_filter.split(',').each do |job|
      assert target.job_include?(job)
    end

  end

  def test_noauth_onejob_nohealthreport
    mydata = hudson_settings(:noauth_onejob_nohealthreport)
    target = HudsonSettings.find( mydata.id )

    assert target.job_include?(mydata.job_filter)
    assert_equal false, target.use_authentication?
    assert_equal 0,target.health_report_settings.length
  end

  def test_noauth_nojob_nohealthreport
    mydata = hudson_settings(:noauth_nojob_nohealthreport)
    target = HudsonSettings.find( mydata.id )

    assert_equal false, target.job_include?('a')
    assert_equal false, target.use_authentication?
    assert_equal 0, target.health_report_settings.length
  end

end
