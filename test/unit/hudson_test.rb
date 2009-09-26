# $Id$
require File.dirname(__FILE__) + '/../test_helper'
require 'uri'
require 'net/http'
require 'mocha'

class HudsonTest < Test::Unit::TestCase
  fixtures :projects, :repositories, :hudson_settings, :hudson_settings_health_reports, :hudson_jobs, :hudson_builds
  set_fixture_class :hudson_settings => HudsonSettings

  def test_get_job_should_hudson_no_job
    
    data_settings = hudson_settings(:noauth_onejob_nohealthreport)
    hudson = Hudson.find(data_settings.project_id)
    
    job = hudson.get_job(nil)
    
    assert job.is_a?(HudsonNoJob)
    
  end

  def test_hudson_api_errors_should_be_empty

    data_settings = hudson_settings(:noauth_onejob_nohealthreport)
    hudson = Hudson.find(data_settings.project_id)

    assert_equal true, hudson.hudson_api_errors.empty?

  end

  def test_hudson_api_errors_should_has_hudson_error

    data_settings = hudson_settings(:noauth_onejob_nohealthreport)
    hudson = Hudson.find(data_settings.project_id)

    hudson.fetch

    assert_equal 1, hudson.hudson_api_errors.length
    error = hudson.hudson_api_errors[0]
    assert error.is_a?(HudsonApiError)
    assert_equal "Hudson", error.class_name
    assert_equal "fetch", error.method_name
    assert error.exception.is_a?(HudsonApiException)

  end

  def test_hudson_api_errors_should_has_job_error

    @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_jobs.stubs(:content_type).returns("text/html")
    @response_jobs.stubs(:body).returns(get_response(:hudson_1_fetch_job))

    Net::HTTP.any_instance.stubs(:request).returns(@response_jobs).then.raises(SocketError)

    data_settings = hudson_settings(:noauth_onejob_nohealthreport)
    hudson = Hudson.find(data_settings.project_id)

    hudson.fetch

    assert_equal 1, hudson.hudson_api_errors.length
    error = hudson.hudson_api_errors[0]
    assert error.is_a?(HudsonApiError)
    assert_equal "HudsonJob", error.class_name
    assert_equal "fetch_builds", error.method_name
    assert error.exception.is_a?(HudsonApiException)

  end

  def test_fetch_hudson_1

    @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_jobs.stubs(:content_type).returns("text/html")
    @response_jobs.stubs(:body).returns(get_response(:hudson_1_fetch_job))

    @response_job_rss = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_job_rss.stubs(:content_type).returns("text/html")
    @response_job_rss.stubs(:body).returns(get_response(:hudson_1_fetch_job_simple_ruby_application_rssAll))

    @response_job_build_detail = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_job_build_detail.stubs(:content_type).returns("text/html")
    @response_job_build_detail.stubs(:body).returns(get_response(:hudson_1_fetch_job_simple_ruby_application_build_detail))

    Net::HTTP.any_instance.stubs(:request).returns(@response_jobs, @response_job_rss, @response_job_build_detail)

    data_settings = hudson_settings(:noauth_onejob_nohealthreport)

    hudson = Hudson.find(data_settings.project_id)
    data_job = hudson_jobs(:noauth_onejob_nohealthreport)
    job = hudson.get_job(data_job.name)
    build = job.get_build("1")
    assert_equal "", build.result
    assert_equal true, build.building?

    hudson.fetch

    hudson = Hudson.find(data_settings.project_id)
    assert hudson != nil

    data_job = hudson_jobs(:noauth_onejob_nohealthreport)
    job = hudson.get_job(data_job.name)
    assert_equal data_job.name, job.name
    assert_equal "red", job.state
    assert_equal "Ruby Small Application", job.description
    assert_equal "3", job.latest_build_number

    assert_equal 2, job.health_reports.length
    healthreport = job.health_reports[0]
    assert_equal "安定したビルド: 最近の5個中、2個ビルドに失敗しました。", healthreport.description
    assert_equal 59, healthreport.score

    healthreport = job.health_reports[1]
    assert_equal "Rcov coverage: Code coverage 70.0%(70.0)", healthreport.description
    assert_equal 87, healthreport.score

    build = job.get_build("1")
    assert_equal "FAILURE", build.result
    assert_equal false, build.building?
    
    changesets = build.changesets
    assert_equal 2, changesets.length
    assert_equal "16", changesets[0].revision
    assert_equal "15", changesets[1].revision

    testresult = build.test_result

    assert_equal 0, testresult.fail_count
    assert_equal 0, testresult.skip_count
    assert_equal 3, testresult.total_count

    build = job.get_build("2")
    assert_equal "SUCCESS", build.result
    assert_equal false, build.building?

    changesets = build.changesets
    assert_equal 1, changesets.length
    assert_equal "17", changesets[0].revision

    testresult = build.test_result

    assert testresult == nil

    build = job.get_build("3")
    assert_equal "", build.result
    assert_equal true, build.building?

  end

  def test_find_all
    items = Hudson.find(:all)

    assert_equal items.length, 4
    
    data_settings = hudson_settings(:noauth_onejob_nohealthreport)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id

    data_settings = hudson_settings(:hasauth_threejob_twohealthreport)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id

    data_settings = hudson_settings(:noauth_nojob_nohealthreport)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id

    data_settings = hudson_settings(:noauth_onenewjob_twohealthreport)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id
  end

end
