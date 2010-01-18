# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildRotatorTest < Test::Unit::TestCase
  fixtures :hudson_jobs, :hudson_job_settings, :hudson_settings, :hudson_settings_health_reports
  set_fixture_class :hudson_settings => HudsonSettings
  set_fixture_class :hudson_job_settings => HudsonJobSettings

  def test_initialize_should_raise_exception

    assert_raise(ArgumentError){HudsonBuildRotator.new(nil)}
    assert_raise(ArgumentError){HudsonBuildRotator.new(Hudson.new)}

  end

  def test_execute_both

    data_job = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(data_job.id, :include => HudsonJobSettings)

    HudsonBuild.delete_all

    create_build data_job.id, Date.today - 2, (1..10)
    create_build data_job.id, Date.today - 1, (11..20)
    create_build data_job.id, Date.today, (21..30)

    assert_equal 30, HudsonBuild.count()

    target = HudsonBuildRotator.new(job.job_settings)
    target.execute

    assert_equal 10, HudsonBuild.count
    count = 0
    HudsonBuild.find(:all).each do |build|
      count += 1 if build.number.to_i >= 11 && build.finished_at > Date.today - 1
    end
    assert_equal 10, count

  end

  def test_execute_enable_num_to_keep

    data_job = hudson_jobs(:have_white_space)
    job = HudsonJob.find(data_job.id, :include => HudsonJobSettings)

    target = HudsonBuildRotator.new(job.job_settings)

    HudsonBuild.delete_all

    create_build data_job.id, Date.today - 2, (1..10)
    create_build data_job.id, Date.today - 1, (11..20)
    create_build data_job.id, Date.today, (21..30)

    target.execute

    assert_equal 15, HudsonBuild.count
    count = 0
    HudsonBuild.find(:all).each do |build|
      count += 1 if build.number.to_i >= 16
    end
    assert_equal 15, count

  end

  def test_execute_enable_days_to_keep

    data_job = hudson_jobs(:maven_application)
    job = HudsonJob.find(data_job.id, :include => HudsonJobSettings)

    target = HudsonBuildRotator.new(job.job_settings)

    HudsonBuild.delete_all

    create_build data_job.id, Date.today - 2, (1..10)
    create_build data_job.id, Date.today - 1, (11..20)
    create_build data_job.id, Date.today, (21..30)

    target.execute

    assert_equal 20, HudsonBuild.count
    count = 0
    HudsonBuild.find(:all).each do |build|
      count += 1 if build.finished_at > Date.today - job.job_settings.build_rotator_days_to_keep
    end
    assert_equal 20, count

  end

  def create_build(job_id, finished_at, number_list)
      number_list.each do |number|
        build = HudsonBuild.new
        build.hudson_job_id = job_id
        build.number = number
        build.result = "SUCCESS"
        build.building = false
        build.finished_at = finished_at
        build.save!
      end
  end

end
