# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildTest < ActiveSupport::TestCase
  fixtures :hudson_builds, :hudson_jobs, :hudson_settings, :hudson_settings_health_reports, :hudson_build_changesets
  set_fixture_class :hudson_settings => HudsonSettings

  def test_url_should_return_zero_length_string
    build = HudsonBuild.new()
    assert_equal "", build.url_for(:user)
    assert_equal "", build.url_for(:plugin)
  end

  def test_url_for
    job = HudsonJob.new()
    job.hudson_id = 1
    job.name = "test-job"
    job.save
    build = HudsonBuild.new()
    build.hudson_job_id = job.id
    build.job = job
    build.number = 10
    assert_equal "http://noauth.onejob.nohealthreport.local:9090/job/test-job/10", build.url_for(:user)
    assert_equal "http://noauth.onejob.nohealthreport.local:19090/job/test-job/10", build.url_for(:plugin)
  end

  def test_event_url_should_return_zero_length_string
    build = HudsonBuild.new()
    assert_equal "", build.event_url
  end

  def test_event_url
    job = HudsonJob.new()
    job.hudson_id = 1
    job.name = "test-job"
    job.save
    build = HudsonBuild.new()
    build.hudson_job_id = job.id
    build.job = job
    build.number = 10
    assert_equal "http://noauth.onejob.nohealthreport.local:9090/job/test-job/10", build.event_url
  end

  def test_building_should_true
    build = HudsonBuild.new()

    build.building = "true"
    assert_equal true, build.building?
  end

  def test_building_should_false
    build = HudsonBuild.new()
    assert_equal false, build.building?

    build.building = "false"
    assert_equal false, build.building?
  end

  def test_find_by_changeset_should_be_HudsonNoBuild
    build = HudsonBuild.find_by_changeset(nil)
    assert build.is_a?(HudsonNoBuild)
  end

  def test_update_by_rss_should_not_update
    rss = "<entry>"
    rss << "<title>simple-ruby-application #2 (SUCCESS)</title><link type='text/html' rel='alternate' href='http://192.168.0.51:8080/job/simple-ruby-application/2/'></link>"
    rss << "<id>tag:hudson.dev.java.net,2009:simple-ruby-application:2009-07-19_20-35-15</id>"
    rss << "<published>2009-07-19T11:35:15Z</published>"
    rss << "<updated>2009-07-19T11:35:15Z</updated>"
    rss << "</entry>"
    doc = REXML::Document.new rss

    build = HudsonBuild.new
    build.number = "3"
    build.result = "FAILURE"
    build.finished_at = Time.xmlschema("2009-07-19T10:35:15Z").localtime
    build.building = "true"

    build.update_by_rss(doc.elements["//entry"])

    assert_equal  3, build.number
    assert_equal "FAILURE", build.result
    assert_equal Time.xmlschema("2009-07-19T10:35:15Z").localtime, build.finished_at
    assert_equal true, build.building?
    
  end

  def test_update_by_rss_should_update_if_number_is_nil
    rss = "<entry>"
    rss << "<title>simple-ruby-application #2 (SUCCESS)</title><link type='text/html' rel='alternate' href='http://192.168.0.51:8080/job/simple-ruby-application/2/'></link>"
    rss << "<id>tag:hudson.dev.java.net,2009:simple-ruby-application:2009-07-19_20-35-15</id>"
    rss << "<published>2009-07-19T11:35:15Z</published>"
    rss << "<updated>2009-07-19T11:35:15Z</updated>"
    rss << "</entry>"
    doc = REXML::Document.new rss

    build = HudsonBuild.new
    build.update_by_rss(doc.elements["//entry"])

    assert_equal 2, build.number
    assert_equal "SUCCESS", build.result
    assert_equal Time.xmlschema("2009-07-19T11:35:15Z").localtime, build.finished_at
    assert_equal false, build.building?
    
  end

  def test_update_by_rss_should_update_if_number_is_same
    rss = "<entry>"
    rss << "<title>simple-ruby-application #2 (SUCCESS)</title><link type='text/html' rel='alternate' href='http://192.168.0.51:8080/job/simple-ruby-application/2/'></link>"
    rss << "<id>tag:hudson.dev.java.net,2009:simple-ruby-application:2009-07-19_20-35-15</id>"
    rss << "<published>2009-07-19T11:35:15Z</published>"
    rss << "<updated>2009-07-19T11:35:15Z</updated>"
    rss << "</entry>"
    doc = REXML::Document.new rss

    build = HudsonBuild.new
    build.number = "2"
    build.update_by_rss(doc.elements["//entry"])

    assert_equal 2, build.number
    assert_equal "SUCCESS", build.result
    assert_equal Time.xmlschema("2009-07-19T11:35:15Z").localtime, build.finished_at
    assert_equal false, build.building?

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
    changeset.comments = ""
    changeset.repository_id = 40
    changeset.committer = "Smith"
    changeset.user_id = 2
    changeset.save

    builds = HudsonBuild.find_by_changeset(changeset)

    assert_equal 1, builds.length
    assert_equal 2, builds[0].id

  end

  def test_hudson_build_parse_rss
    rss = "<entry>"
    rss << "<title>simple-ruby-application #2 (SUCCESS)</title><link type='text/html' rel='alternate' href='http://192.168.0.51:8080/job/simple-ruby-application/2/'></link>"
    rss << "<id>tag:hudson.dev.java.net,2009:simple-ruby-application:2009-07-19_20-35-15</id>"
    rss << "<published>2009-07-19T11:35:15Z</published>"
    rss << "<updated>2009-07-19T11:35:15Z</updated>"
    rss << "</entry>"
    doc = REXML::Document.new rss
    
    buildinfo = HudsonBuild.parse_rss(doc.elements["//entry"])

    assert_equal "simple-ruby-application", buildinfo[:name]
    assert_equal "2", buildinfo[:number]
    assert_equal "SUCCESS", buildinfo[:result]
    assert_equal Time.xmlschema("2009-07-19T11:35:15Z").localtime, buildinfo[:published]
    assert_equal "http://192.168.0.51:8080/job/simple-ruby-application/2/", buildinfo[:url]
    assert_equal "false", buildinfo[:building]
  end

  def test_hudson_build_exists_number_should_false
    assert_equal false, HudsonBuild.exists_number?(100,10)
  end

  def test_hudson_build_exists_number_should_true
    build = HudsonBuild.new()
    build.hudson_job_id = 100
    build.number = 10
    build.save

    assert_equal true, HudsonBuild.exists_number?(100,10)
  end

  def test_hudson_build_count_of_should_return_zero
    assert_equal 0, HudsonBuild.count_of(nil)

    job_data = hudson_jobs(:have_white_space)
    job = HudsonJob.find(job_data.id)
    assert job != nil
    assert_equal 0, HudsonBuild.count_of(job)
  end

  def test_hudson_build_count_of
    job_data = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(job_data.id)
    assert job != nil
    assert_equal 1, HudsonBuild.count_of(job)
  end

end
