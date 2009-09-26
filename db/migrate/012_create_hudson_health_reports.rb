# $Id: 004_create_hudson_jobs.rb 175 2009-06-27 15:42:20Z toshiyuki.ando1971 $
class CreateHudsonHealthReports < ActiveRecord::Migration
  def self.up
    create_table :hudson_health_reports do |t|
      t.column :hudson_job_id, :integer
      t.column :description, :text
      t.column :score, :integer
      t.column :url, :string
    end
  end

  def self.down
    drop_table :hudson_health_reports
  end
end
