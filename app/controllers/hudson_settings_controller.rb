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
      @settings.show_compact = params[:settings].fetch(:show_compact) if params[:settings][:show_compact] != nil
      @settings.show_compact = false if params[:settings][:show_compact] == nil
      @settings.health_report_build_stability = params[:settings].fetch(:health_report_build_stability)
      @settings.health_report_test_result = params[:settings].fetch(:health_report_test_result)

      if ( @settings.save )
        flash[:notice] = l(:notice_successful_update)
      end
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
        builds = HudsonBuild.find :all, :conditions => ["#{HudsonBuild.table_name}.hudson_job_id = ?", job.id]
        builds.each {|build| build.destroy}
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

end
