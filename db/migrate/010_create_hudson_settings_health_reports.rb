# $Id$

class CreateHudsonSettingsHealthReports < ActiveRecord::Migration
  def self.up
    create_table :hudson_settings_health_reports do |t|
      t.column :hudson_settings_id, :int
      t.column :keyword, :string
      t.column :url_format, :string
    end
    settings = HudsonSettings.find(:all)
    settings.each { |setting|
      HudsonSettingsHealthReport.create(:hudson_settings_id => setting.id, 
                                        :keyword => setting.health_report_build_stability,
                                        :url_format => "${hudson.url}job/${job.name}/lastBuild/") if setting.health_report_build_stability != nil && setting.health_report_build_stability != ""
      HudsonSettingsHealthReport.create(:hudson_settings_id => setting.id,
                                        :keyword => setting.health_report_test_result,
                                        :url_format => "${hudson.url}job/${job.name}/lastBuild/testReport/"  ) if setting.health_report_test_result != nil && setting.health_report_test_result != ""
    }
    remove_column :hudson_settings, :health_report_build_stability
    remove_column :hudson_settings, :health_report_test_result
  end

  def self.down
    drop_table :hudson_settings_health_reports
    add_column :hudson_settings, :health_report_build_stability, :string, :default => "Build stability"
    add_column :hudson_settings, :health_report_test_result, :string, :default => "Test Result"
    HudsonSettings.update_all "health_report_build_stability = 'Build stability'"
    HudsonSettings.update_all "health_report_test_result = 'Test Result'"
  end
end
