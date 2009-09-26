# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonSettingsTest < Test::Unit::TestCase
  fixtures :hudson_jobs, :hudson_builds, :hudson_settings, :hudson_settings_health_reports
  set_fixture_class :hudson_settings => HudsonSettings

  def test_url
    data = hudson_jobs(:noauth_onejob_nohealthreport)
    settings = hudson_settings(:noauth_onejob_nohealthreport)
    target = HudsonJob.find(data.id)
    assert_equal "#{settings.url}job/#{data.name}", target.url
  end

  def test_latest_build_should_be_nobuild
    data = hudson_jobs(:noauth_onejob_nohealthreport)
    target = HudsonJob.find(data.id)
    assert target.latest_build.is_a?(HudsonNoBuild)
  end

  def test_hudson_api_errors_should_be_empty
    data = hudson_jobs(:noauth_onejob_nohealthreport)
    target = HudsonJob.find(data.id)

    assert target.hudson_api_errors.empty?
  end

  def test_hudson_api_errors_should_has_socketerror
    data = hudson_jobs(:noauth_onejob_nohealthreport)
    target = HudsonJob.find(data.id)

    target.fetch_builds

    assert_equal 1, target.hudson_api_errors.length
    error = target.hudson_api_errors[0]
    assert error.is_a?(HudsonApiError)
    assert_equal "HudsonJob", error.class_name
    assert_equal "fetch_builds", error.method_name
    assert error.exception.is_a?(HudsonApiException)
    
  end

  def test_get_build
    data = hudson_builds(:noauth_onejob_nohealthreport_No1)
    job = HudsonJob.find(data.hudson_job_id)
    target = job.get_build(data.number)
    assert_equal data.number, target.number
    assert_equal data.building, target.building
  end

end
