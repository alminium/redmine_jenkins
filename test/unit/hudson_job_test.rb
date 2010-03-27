# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonSettingsTest < ActiveSupport::TestCase
  fixtures :hudson_jobs, :hudson_builds, :hudson_settings, :hudson_settings_health_reports
  set_fixture_class :hudson_settings => HudsonSettings

  def test_url_for_should_return_zero_length_string

    name_nil_job = HudsonJob.new # settings がない
    name_zero_length_job = HudsonJob.new(:name => "")
    [:for_user, :for_plugin].each do |type|
      assert_equal "", name_nil_job.url_for(type)
      assert_equal "", name_zero_length_job.url_for(type)
    end


    settings = hudson_settings(:one)
    name_nil_job.settings = settings
    name_zero_length_job.settings = settings

    [:for_user, :for_plugin].each do |type|
      assert_equal "", name_nil_job.url_for(type)
      assert_equal "", name_zero_length_job.url_for(type)
    end
  end

  def test_url_to
    data = hudson_jobs(:simple_ruby_application)
    settings = hudson_settings(:one)
    
    job = HudsonJob.find(data.id)

    assert_equal "#{settings.url}job/#{data.name}", job.url_for(:user)
    assert_equal "#{settings.url_for_plugin}job/#{data.name}", job.url_for(:plugin)

  end

  def test_latest_build_should_be_nobuild
    data = hudson_jobs(:simple_ruby_application)
    target = HudsonJob.find(data.id)
    assert target.latest_build.is_a?(HudsonNoBuild)
  end

  def test_hudson_api_errors_should_be_empty
    data = hudson_jobs(:simple_ruby_application)
    target = HudsonJob.find(data.id)

    assert target.hudson_api_errors.empty?
  end

  def test_hudson_api_errors_should_has_socketerror
    data = hudson_jobs(:simple_ruby_application)
    target = HudsonJob.find(data.id)

    target.fetch_builds

    assert_equal 1, target.hudson_api_errors.length
    error = target.hudson_api_errors[0]
    assert error.is_a?(HudsonApiError)
    assert_equal "HudsonJob", error.class_name
    assert_equal "fetch_builds 'simple-ruby-application'", error.method_name
    assert error.exception.is_a?(HudsonApiException)
    
  end

  def test_get_build
    data = hudson_builds(:simple_ruby_application_build1)
    job = HudsonJob.find(data.hudson_job_id)
    target = job.get_build(data.number)
    assert_equal data.number, target.number
    assert_equal data.building, target.building
  end

  def test_request_build
    @response = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response.stubs(:content_type).returns("text/html")
    @response.stubs(:body).returns("")

    Net::HTTP.any_instance.stubs(:request).returns(@response)

    data = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(data.id)
    job.expects(:open_hudson_api).with("http://noauth.onejob.nohealthreport.local:19090/job/simple-ruby-application/build", nil, nil)

    job.request_build
  end

  def test_fetch_recent_builds

    @response = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response.stubs(:content_type).returns("text/html")
    @response.stubs(:body).returns(get_response(:hudson_1_fetch_job_simple_ruby_application_rssAll))

    Net::HTTP.any_instance.stubs(:request).returns(@response)

    data = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(data.id)
    target = job.fetch_recent_builds

    assert_equal 2, target.length

  end

  def test_destory_builds

    data_job = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(data_job.id)

    job.destroy_builds

    target = HudsonBuild.find(:all)

    assert_equal 1, target.length
    assert_equal 2, target[0].id
    assert_equal 5, target[0].hudson_job_id

  end

  def test_job_settings
    target = HudsonJob.new(:project_id => 1, :hudson_id => 1, :name => 'test_job_settings')

    assert_equal nil, target.id

    target.save!

    assert target.job_settings != nil
    assert target.id != nil
    assert_equal target.id, target.job_settings.hudson_job_id

  end

end
