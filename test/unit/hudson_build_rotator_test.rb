# $Id$

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildRotatorTest < ActiveSupport::TestCase
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

    curdate = DateTime.now
    curdate = DateTime.new(curdate.year, curdate.month, curdate.day, 12, 0, 0)
    (0..1).each do |index|
      create_build data_job.id + index, curdate - 2, (1..10)
      create_build data_job.id + index, curdate - 1, (11..20)
      create_build data_job.id + index, curdate, (21..30)
    end

    assert_equal 60, HudsonBuild.count()

    target = HudsonBuildRotator.new(job.job_settings)
    target.execute

    assert_equal 30, HudsonBuild.count_by_sql(["select count(*) from #{HudsonBuild.table_name} where hudson_job_id = ?", data_job.id + 1])
    count = 0
    oldest_date_remain = curdate - job.job_settings.build_rotator_days_to_keep
    oldest_date_remain = DateTime.new(oldest_date_remain.year, oldest_date_remain.month, oldest_date_remain.day, 0, 0, 0)
    HudsonBuild.find(:all, :conditions => ["hudson_job_id = ?", data_job.id]).each do |build|
      count += 1 if build.number.to_i >= 26 && build.finished_at >= oldest_date_remain
    end
    assert_equal 5, count

  end

  def test_execute_enable_num_to_keep

    data_job = hudson_jobs(:have_white_space)
    job = HudsonJob.find(data_job.id, :include => HudsonJobSettings)

    HudsonBuild.delete_all

    curdate = DateTime.now
    curdate = DateTime.new(curdate.year, curdate.month, curdate.day, 12, 0, 0)
    (0..1).each do |index|
      create_build data_job.id + index, curdate - 2, (1..10)
      create_build data_job.id + index, curdate - 1, (11..20)
      create_build data_job.id + index, curdate, (21..30)
    end

    target = HudsonBuildRotator.new(job.job_settings)
    target.execute

    assert_equal 35, HudsonBuild.count
    assert_equal 30, HudsonBuild.count_by_sql(["select count(*) from #{HudsonBuild.table_name} where hudson_job_id = ?", data_job.id + 1])
    count = 0
    HudsonBuild.find(:all, :conditions => ["hudson_job_id = ?", data_job.id]).each do |build|
      count += 1 if build.number.to_i >= 26
    end
    assert_equal 5, count

  end

  def test_execute_enable_days_to_keep

    data_job = hudson_jobs(:maven_application)
    job = HudsonJob.find(data_job.id, :include => HudsonJobSettings)

    target = HudsonBuildRotator.new(job.job_settings)

    HudsonBuild.delete_all

    curdate = DateTime.now
    curdate = DateTime.new(curdate.year, curdate.month, curdate.day, 12, 0, 0)
    (0..1).each do |index|
      create_build data_job.id + index, curdate - 2, (1..10)
      create_build data_job.id + index, curdate - 1, (11..20)
      create_build data_job.id + index, curdate, (21..30)
    end

    target.execute

    assert_equal 50, HudsonBuild.count
    assert_equal 30, HudsonBuild.count_by_sql(["select count(*) from #{HudsonBuild.table_name} where hudson_job_id = ?", data_job.id + 1])
    count = 0
    oldest_date_remain = curdate - job.job_settings.build_rotator_days_to_keep
    oldest_date_remain = DateTime.new(oldest_date_remain.year, oldest_date_remain.month, oldest_date_remain.day, 0, 0, 0)
    HudsonBuild.find(:all, :conditions => ["hudson_job_id = ?", data_job.id]).each do |build|
      count += 1 if build.finished_at >= oldest_date_remain
    end
    assert_equal 20, count

  end

  def test_self_can_store_should_return_false

    data_job = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(data_job.id, :include => HudsonJobSettings)

    HudsonBuild.delete_all

    curdate = DateTime.now
    curdate = DateTime.new(curdate.year, curdate.month, curdate.day, 12, 0, 0)
    (0..1).each do |index|
      create_build data_job.id + index, curdate - 2, (1..10)
      create_build data_job.id + index, curdate - 1, (11..20)
      create_build data_job.id + index, curdate, (21..30)
    end

    assert_equal false, HudsonBuildRotator.can_store?(nil, nil)
    assert_equal false, HudsonBuildRotator.can_store?(nil, 1)
    assert_equal false, HudsonBuildRotator.can_store?(nil, "1")

    assert_equal false, HudsonBuildRotator.can_store?(job, 1)
    assert_equal false, HudsonBuildRotator.can_store?(job, "1")
    assert_equal false, HudsonBuildRotator.can_store?(job, 20)
    assert_equal false, HudsonBuildRotator.can_store?(job, "20")

  end

  def test_self_can_store_should_return_true

    data_job = hudson_jobs(:simple_ruby_application)
    job = HudsonJob.find(data_job.id, :include => HudsonJobSettings)

    HudsonBuild.delete_all

    curdate = DateTime.now
    curdate = DateTime.new(curdate.year, curdate.month, curdate.day, 12, 0, 0)
    (0..1).each do |index|
      create_build data_job.id + index, curdate - 2, (1..10)
      create_build data_job.id + index, curdate - 1, (11..20)
      create_build data_job.id + index, curdate, (21..30)
    end

    assert_equal true, HudsonBuildRotator.can_store?(job, 31)
    assert_equal true, HudsonBuildRotator.can_store?(job, "31")

  end

  def create_build(job_id, finished_at, number_list)
      number_list.each do |number|
        build = HudsonBuild.new
        build.hudson_job_id = job_id
        build.number = number
        build.result = "SUCCESS"
        build.building = false
        build.finished_at = finished_at + Rational(1, 24 * 60 * 60) * number
        build.save!
      end
  end

end
