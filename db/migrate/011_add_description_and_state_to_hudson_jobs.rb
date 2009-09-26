# $Id$

class AddDescriptionAndStateToHudsonJobs < ActiveRecord::Migration
  def self.up
    add_column :hudson_jobs, :description, :text
    add_column :hudson_jobs, :state, :string
  end

  def self.down
    remove_column :hudson_jobs, :description
    remove_column :hudson_jobs, :state
  end
end
