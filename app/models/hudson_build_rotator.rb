# To change this template, choose Tools | Templates
# and open the template in the editor.

class HudsonBuildRotator

  def initialize(job_settings)
    raise ArgumentError.new("arg job_settings is nil") unless job_settings
    raise ArgumentError.new("arg job_settings should be HudsonJobSetting") unless job_settings.is_a?(HudsonJobSettings)
    @job_settings = job_settings
  end

  def execute
    return unless @job_settings.do_rotate?

    cond = "hudson_job_id = #{@job_settings.hudson_job_id}"

    delete_conds = []
    delete_conds << create_cond_days_to_delete(@job_settings.build_rotator_days_to_keep)
    delete_conds << create_cond_num_to_delete(@job_settings.build_rotator_num_to_keep)
    delete_conds.delete("")

    delete_cond = delete_conds.join(" OR ")

    cond << " AND (#{delete_cond})"

    HudsonBuild.delete_all(cond)

  end

private
  def create_cond_days_to_delete(days_to_keep)
    return "" unless (days_to_keep && days_to_keep > 0)

    date_to_delete = Date.today - days_to_keep
    return "finished_at <= '#{date_to_delete}'"
  end

  def create_cond_num_to_delete(num_to_keep)
    return "" unless (num_to_keep && num_to_keep > 0)

    return "id not in (select id from #{HudsonBuild.table_name} order by id desc limit #{num_to_keep})"
  end

end
