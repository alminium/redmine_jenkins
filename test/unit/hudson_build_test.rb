# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildTest < Test::Unit::TestCase
  fixtures :hudson_builds, :hudson_jobs, :hudson_settings, :hudson_settings_health_reports, :hudson_build_changesets
  set_fixture_class :hudson_settings => HudsonSettings

  def test_building_should_false
    build = HudsonBuild.new()
    assert_equal false, build.building?

    build.building = "f"
    assert_equal false, build.building?
  end

  def test_find_by_changeset_should_be_HudsonNoBuild
    build = HudsonBuild.find_by_changeset(nil)
    assert build.is_a?(HudsonNoBuild)
  end

  def test_find_by_changeset_should_be_returns_build_id_2

    repo = Repository.new()
    repo.url = "svn://localhost/test"
    repo.id = 40
    repo.project_id = 4
    repo.type = "Subversion"
    repo.save

    changeset = Changeset.new()
    changeset.repository = repo
    changeset.repository_id = repo.id
    changeset.commit_date = "2007-04-12"
    changeset.committed_on = "2007-04-12 15:14:44 +02:00"
    changeset.revision = "110"
    changeset.comments = "This commit fixes #1, #2 and references #1 & #3"
    changeset.repository_id = 40
    changeset.committer = "Smith"
    changeset.user_id = 2
    changeset.save

    builds = HudsonBuild.find_by_changeset(changeset)

    assert_equal 1, builds.length
    assert_equal 2, builds[0].id

  end

  def test_building_should_true
    build = HudsonBuild.new()

    build.building = "t"
    assert_equal true, build.building?
  end

end
