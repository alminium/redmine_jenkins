require File.join(File.dirname(__FILE__), "../../app/models", 'hudson_job_settings')

class CreateHudsonJobSettings < ActiveRecord::Migration
  def self.up
    create_table :hudson_job_settings do |t|
      t.column :hudson_job_id, :integer
      t.column :build_rotate, :boolean, :default => false
      t.column :build_rotator_days_to_keep, :integer, :default => -1
      t.column :build_rotator_num_to_keep, :integer, :default => -1
    end
  end

  def self.down
    drop_table :hudson_job_settings
  end
end
