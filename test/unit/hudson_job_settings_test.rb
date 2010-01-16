# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonJobSettingsTest < Test::Unit::TestCase
  fixtures :hudson_settings, :hudson_settings_health_reports
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

    data = hudson_settings(:one)
    settings = HudsonSettings.find(data.id)

    target = HudsonJobSettings.fetch(settings, "simple-ruby-application")

    assert target.is_a?(HudsonJobSettings)
    assert_equal true, target.build_rotate
    assert_equal 100, target.build_rotator_days_to_keep
    assert_equal -1, target.build_rotator_num_to_keep

  end

end
