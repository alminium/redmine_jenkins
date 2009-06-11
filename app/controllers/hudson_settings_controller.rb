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

      if ( @settings.save )
        flash[:notice] = l(:notice_successful_update)
      end
    end

    # この find は、外部のサーバ(Hudson)にアクセスするので、before_filter には入れない
    find_hudson_jobs(@settings.url)

  rescue HudsonHttpError => error
    flash.now[:error] = l(:notice_err_http_error, error.message)
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT 
    flash.now[:error] = l(:notice_err_cant_connect)
  rescue URI::InvalidURIError
    flash.now[:error] = l(:notice_err_invalid_url)
  end

  def joblist
    begin
      # この find は、外部のサーバ(Hudson)にアクセスするので、before_filter には入れない
      find_hudson_jobs(params[:url])
    rescue HudsonHttpError => error
      flash.now[:error] = l(:notice_err_http_error, error.message)
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT 
      @error = l(:notice_err_cant_connect)
    rescue URI::InvalidURIError
      @error = l(:notice_err_invalid_url)
    end
    render :layout => false, :template => 'hudson_settings/_joblist.rhtml'
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
