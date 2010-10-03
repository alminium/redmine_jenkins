# To change this template, choose Tools | Templates
# and open the template in the editor.

class HudsonBuildRotator
  unloadable
  
  def initialize(job_settings)
    raise ArgumentError.new("arg job_settings is nil") unless job_settings
    raise ArgumentError.new("arg job_settings should be HudsonJobSetting") unless job_settings.is_a?(HudsonJobSettings)
    @job_settings = job_settings
  end

  def execute
    return unless @job_settings.do_rotate?

    HudsonBuild.destroy_all(HudsonBuildRotator.create_cond_to_delete(@job_settings))

  end

end

def HudsonBuildRotator.can_store?(job, number)
  return false unless job
  return false unless number

  job_settings = job.job_settings
  return true unless job_settings
  return true unless job_settings.do_rotate?

  cond = HudsonBuildRotator.create_cond_to_delete(job_settings)

  # get oldest data
  oldest = HudsonBuild.find(:first,
                            :conditions => ["#{HudsonBuild.table_name}.hudson_job_id = ? and #{HudsonBuild.table_name}.id not in (select #{HudsonBuild.table_name}.id from #{HudsonBuild.table_name} where #{cond})", job.id],
                            :order => "#{HudsonBuild.table_name}.number")

  return true unless oldest

  return number.to_i >= oldest.number.to_i

end

def HudsonBuildRotator.create_cond_to_delete(job_settings)

  cond = "#{HudsonBuild.table_name}.hudson_job_id = #{job_settings.hudson_job_id}"

  delete_conds = []
  delete_conds << HudsonBuildRotator.create_cond_days_to_delete(job_settings.build_rotator_days_to_keep)
  delete_conds << HudsonBuildRotator.create_cond_num_to_delete(job_settings.hudson_job_id, job_settings.build_rotator_num_to_keep)
  delete_conds.delete("")

  delete_cond = delete_conds.join(" OR ")

  cond << " AND (#{delete_cond})"

  return cond

end

def HudsonBuildRotator.create_cond_days_to_delete(days_to_keep)
  return "" unless (days_to_keep && days_to_keep > 0)

  date_to_delete = Date.today - days_to_keep
  return "#{HudsonBuild.table_name}.finished_at <= '#{date_to_delete} 23:59:59'"
end

def HudsonBuildRotator.create_cond_num_to_delete(job_id, num_to_keep)
  return "" unless (num_to_keep && num_to_keep > 0)

  # because, MySQL can't use limit in subquery
  # http://dev.mysql.com/doc/refman/5.0/en/subquery-errors.html
  build_count = HudsonBuild.count(:conditions => "#{HudsonBuild.table_name}.hudson_job_id = #{job_id}")
  delete_count = build_count - num_to_keep

  return "" unless delete_count > 0

  delete_builds = HudsonBuild.find(:all, :conditions => "#{HudsonBuild.table_name}.hudson_job_id = #{job_id}", :order => "#{HudsonBuild.table_name}.number ASC", :limit => delete_count, :offset => delete_count - 1)
  return "" unless delete_builds.length > 0

  return "#{HudsonBuild.table_name}.number <= #{delete_builds[0].number}"
end
