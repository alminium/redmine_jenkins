# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildChangesetTest < ActiveSupport::TestCase

  def test_description_for_activity_should_return_zero_length_string
    target = HudsonBuildChangeset.new
    assert_equal "", target.description_for_activity
  end

  def test_description_for_activity
    target = HudsonBuildChangeset.new
    target.revision = "15"
    assert_equal "r15", target.description_for_activity
  end

  def test_hudson_changeset_description_for_activity_should_return_zero_length_string
    list = []
    assert_equal "", HudsonBuildChangeset.description_for_activity(list)
  end

  def test_hudson_changeset_description_for_activity
    list = []
    list << HudsonBuildChangeset.new(:revision => "10")
    list << HudsonBuildChangeset.new(:revision => "12")
    assert_equal "Changesets: r10, r12", HudsonBuildChangeset.description_for_activity(list)
  end
end
