# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildTestResultTest < ActiveSupport::TestCase

  def test_description_for_activity

    target = HudsonBuildTestResult.new
    target.fail_count = 3
    target.skip_count = 2
    target.total_count = 5

    assert_equal "TestResults: 3Failed 2Skipped Total-5", target.description_for_activity

  end

end
