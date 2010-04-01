# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildArtifactTest < ActiveSupport::TestCase

  def test_artifact_cannot_save_without_required
    target = HudsonBuildArtifact.new
    target.save
    assert_equal "can't be blank", target.errors["hudson_build_id"]
    assert_equal "can't be blank", target.errors["display_path"]
    assert_equal "can't be blank", target.errors["file_name"]
    assert_equal "can't be blank", target.errors["relative_path"]
  end

end
