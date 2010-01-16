# $Id: 004_create_hudson_jobs.rb 175 2009-06-27 15:42:20Z toshiyuki.ando1971 $

require 'hudson_job_settings'

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
    drop_table :hudson_job_config
  end
end
