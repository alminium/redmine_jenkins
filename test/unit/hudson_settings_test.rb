# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonSettingsTest < ActiveSupport::TestCase
  fixtures :hudson_settings, :hudson_settings_health_reports
  set_fixture_class :hudson_settings => HudsonSettings

  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  def test_job_include_should_be_false
    mydata = hudson_settings(:one)
    target = HudsonSettings.find( mydata.id )
    assert_equal false, target.job_include?(mydata.job_filter + "--")
  end

  def test_add_last_slash_to_url_should_add
    url = "abc"
    target = HudsonSettings.add_last_slash_to_url(url)
    assert_equal "abc/", target
  end

  def test_add_last_slash_to_url_should_not_add
    url = "test/"
    target = HudsonSettings.add_last_slash_to_url(url)
    assert_equal "test/", target

    url = ""
    target = HudsonSettings.add_last_slash_to_url(url)
    assert_equal "", target
  end

  def test_hudson_settings_human_attribute_name
    assert_equal l(:label_health_report_settings), HudsonSettings.human_attribute_name("health_report_settings")
  end

  def test_hudson_settings_to_array_should_return_empty
    assert HudsonSettings.to_array(nil).empty?
    assert HudsonSettings.to_array("").empty?
  end

  def test_hudson_settings_to_array
    target = HudsonSettings.to_array("a,b,c")
    assert_equal 3, target.length
    assert_equal "a", target[0]
    assert_equal "b", target[1]
    assert_equal "c", target[2]
  end

  def test_hudson_settings_to_value_should_return_zero_length_string
    assert_equal "", HudsonSettings.to_value(nil)
    assert_equal "", HudsonSettings.to_value([])
    assert_equal "", HudsonSettings.to_value("")
  end

  def test_hudson_settings_to_value_should_return_zero_length_string
    assert_equal "a,b,c", HudsonSettings.to_value(['a','b','c'])
  end

  def test_noauth_onejob_nohealthreport
    mydata = hudson_settings(:one)
    target = HudsonSettings.find( mydata.id )

    assert target.job_include?(mydata.job_filter)
    assert_equal false, target.use_authentication?
    assert_equal 0,target.health_report_settings.length
  end

  def test_hasauth_threejob_twohealthreport
    mydata = hudson_settings(:two)
    target = HudsonSettings.find_by_project_id( mydata.project_id )

    assert_equal true, target.use_authentication?
    assert_equal 2, target.health_report_settings.length

    mydata.job_filter.split(',').each do |job|
      assert target.job_include?(job)
    end

  end

  def test_noauth_nojob_nohealthreport
    mydata = hudson_settings(:three)
    target = HudsonSettings.find( mydata.id )

    assert_equal false, target.job_include?('a')
    assert_equal false, target.use_authentication?
    assert_equal 0, target.health_report_settings.length
  end

end
