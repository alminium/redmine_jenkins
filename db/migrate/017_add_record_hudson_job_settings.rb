# $Id$

class AddRecordHudsonJobSettings < ActiveRecord::Migration
  def self.up
    HudsonJob.find(:all).each do |job|
      settings = HudsonJobSettings.new
      settings.hudson_job_id = job.id
      settings.save!
    end
  end

  def self.down

  end
end
