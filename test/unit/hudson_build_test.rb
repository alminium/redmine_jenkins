# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildTest < Test::Unit::TestCase
  fixtures :hudson_builds, :hudson_jobs, :hudson_settings, :hudson_settings_health_reports
  set_fixture_class :hudson_settings => HudsonSettings

  def test_building_should_false
    build = HudsonBuild.new()
    assert_equal false, build.building?

    build.building = "f"
    assert_equal false, build.building?
  end

  def test_building_should_true
    build = HudsonBuild.new()

    build.building = "t"
    assert_equal true, build.building?
  end

end
