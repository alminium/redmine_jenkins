# $Id$

class HudsonNoBuildTest < ActiveSupport::TestCase

  def test_building_should_return_false
    target = HudsonNoBuild.new
    assert_equal false, target.building?
  end
  
end
