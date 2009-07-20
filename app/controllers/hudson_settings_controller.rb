# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "rexml/document"
require 'hudson_exceptions'

class HudsonSettingsController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project
  before_filter :find_settings
  before_filter :authorize
  before_filter :clear_flash

  include RexmlHelper
  include HudsonHelper

  def edit
    if (params[:settings] != nil)
      @settings.project_id = @project.id
      @settings.url = params[:settings].fetch(:url)
      @settings.job_filter = HudsonSettings.to_value(params[:settings].fetch(:jobs))
      @settings.auth_user = params[:settings].fetch(:auth_user)
      @settings.auth_password = params[:settings].fetch(:auth_password)
      @settings.get_build_details = check_box_to_boolean(params[:settings][:get_build_details])
      @settings.show_compact = check_box_to_boolean(params[:settings][:show_compact])
      @settings.look_and_feel = params[:settings].fetch(:look_and_feel)

      if (params[:health_report_settings] != nil)
        params[:health_report_settings].each do |id, hrs|
          setting = @settings.health_report_settings.detect {|item| item.id == id.to_i}
          next unless setting
          setting.destroy if HudsonSettingsHealthReport.is_blank?(hrs)
          unless HudsonSettingsHealthReport.is_blank?(hrs)
            setting.update_from_hash(hrs)
            setting.save
          end
        end
      end

      if (params[:new_health_report_settings] != nil)
        params[:new_health_report_settings].each do |id, hrs|
          next if HudsonSettingsHealthReport.is_blank?(hrs)
          @settings.health_report_settings << HudsonSettingsHealthReport.new(hrs)
        end
      end

      if ( @settings.save )
        flash[:notice] = l(:notice_successful_update)
      end

      destroy_garbage_jobs
    end

    # この find は、外部のサーバ(Hudson)にアクセスするので、before_filter には入れない
    find_hudson_jobs(@settings.url)

  rescue HudsonHttpException => error
    flash.now[:error] = error.message
  end

  def joblist
    begin
      # この find は、外部のサーバ(Hudson)にアクセスするので、before_filter には入れない
      find_hudson_jobs(params[:url])
    rescue HudsonHttpException => error
      @error = error.message
    end
    render :layout => false, :template => 'hudson_settings/_joblist.rhtml'
  end

  def delete_history
    jobs = HudsonJob.find :all, :order => "#{HudsonJob.table_name}.name",
                          :conditions => ["#{HudsonJob.table_name}.project_id = ?", @project.id]
    jobs.each {|job|
      ActiveRecord::Base::transaction() do
        job.destory_builds
        job.destroy
      end
    }

    flash[:notice] = l(:notice_successful_delete)
  rescue Exception => error
    flash[:error] = error.message
  ensure
    find_hudson_jobs(@settings.url)
    render(:action => "edit")
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_settings
    @settings = HudsonSettings.load(@project)
  end

  def clear_flash
    flash.clear
  end

  def find_hudson_jobs(url)
    @jobs = []

    return if url == nil || url.length == 0

    api_url = "#{url}api/xml?depth=0"

    # Open the feed and parse it
    content = open_hudson(api_url, @settings.auth_user, @settings.auth_password)
    doc = REXML::Document.new content
    doc.elements.each("hudson/job") do |element|
      @jobs << get_element_value(element, "name")
    end
  end

  def destroy_garbage_jobs()
    jobs = HudsonJob.find :all, :order => "#{HudsonJob.table_name}.name",
                           :conditions => ["#{HudsonJob.table_name}.project_id = ?", @project.id]
    jobs.each {|job|
      next if @settings.job_include?(job.name)
      ActiveRecord::Base::transaction() do
        job.destory_builds
        job.destroy
      end
    }
  end

end
