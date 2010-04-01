# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonJobSettingsTest < ActiveSupport::TestCase
  fixtures :hudson_settings, :hudson_settings_health_reports, :hudson_jobs
  set_fixture_class :hudson_settings => HudsonSettings

  def test_initialize
    
    target = HudsonJobSettings.new

    assert_equal false, target.build_rotate
    assert_equal -1, target.build_rotator_days_to_keep
    assert_equal -1, target.build_rotator_num_to_keep
    
  end

  def test_fetch_using_settings
    
    @response = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response.stubs(:content_type).returns("text/html")
    @response.stubs(:body).returns(get_response(:hudson_simple_ruby_application_config))

    Net::HTTP.any_instance.stubs(:request).returns(@response)

    data = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(data.id)

    job.job_settings.fetch

    assert_equal true, job.job_settings.build_rotate
    assert_equal 100, job.job_settings.build_rotator_days_to_keep
    assert_equal -1, job.job_settings.build_rotator_num_to_keep

  end

end
