# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "rexml/document"
require 'cgi'
require 'hudson_exceptions'
require 'date'

RAILS_DEFAULT_LOGGER.info 'Starting Hudson plugin for RedMine'

class HudsonController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project
  before_filter :find_hudson
  before_filter :authorize
  before_filter :clear_flash

  include HudsonHelper
  include RexmlHelper
  include ERB::Util

  def index
    raise HudsonNoSettingsException if @hudson.settings.new_record?

    @hudson.fetch if Hudson.autofetch?
       
    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr? }
      format.atom { render :layout => false, :template => 'hudson/index.atom.builder', :type => 'text/xml' } 
    end
    
  rescue HudsonNoSettingsException
    flash.now[:error] = l(:notice_err_no_settings, url_for(:controller => 'hudson_settings', :action => 'edit', :id => @project))
  ensure
    unless @hudson.hudson_api_errors.empty?
      flash.now[:error] << "<br>" if flash.now[:error]
      flash.now[:error] = "" unless flash.now[:error]
      api_error_messages = hudson_api_errors_to_messages(@hudson.hudson_api_errors)
      flash.now[:error] << "#{api_error_messages.join('<br>')}"
    end
  end

  def build
    raise HudsonNoSettingsException if @hudson.settings.new_record?

    job = @hudson.get_job(params[:name])

    raise HudsonNoJobException if job.is_a?(HudsonNoJob)

    job.request_build

  rescue HudsonNoSettingsException
    render :text => "#{l(:notice_err_build_failed, :notice_err_no_settings)}"
  rescue HudsonNoJobException
    render :text => "#{l(:notice_err_build_failed_no_job, params[:name])}"
  else
    if job.hudson_api_errors.empty?
      render :text => "#{params[:name]} #{l(:build_accepted)}"
    else
      api_error_messages = hudson_api_errors_to_messages(job.hudson_api_errors)
      render :text => api_error_messages.join("<br>")
    end
  end

  def history
    raise HudsonNoSettingsException if @hudson.settings.new_record?
    raise HudsonNoJobException unless @hudson.settings.job_include?(params[:name]) # ちょっと強引だけど、見えない設定のジョブはないものとみなす

    job = @hudson.get_job(params[:name])

    raise HudsonNoJobException if job.is_a?(HudsonNoJob)

    @builds = job.fetch_recent_builds

  rescue HudsonNoSettingsException
    render :text => "#{l(:notice_err_no_settings, url_for(:controller => 'hudson_settings', :action => 'edit', :id => @project))}"
  rescue HudsonNoJobException
    render :text => "#{l(:notice_err_no_job, params[:name])}"
  else
    if job.hudson_api_errors.empty?
      render :partial => 'history'
    else
      api_error_messages = hudson_api_errors_to_messages(@hudson.hudson_api_errors)
      render :text => api_error_messages.join("<br>")
    end
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_hudson
    @hudson = Hudson.find_by_project_id(@project.id)
  end

  def clear_flash
    flash.clear
  end

  def hudson_api_errors_to_messages(hudson_api_errors)
      retval = []
      hudson_api_errors.each {|api_error|
        retval << "HudsonApiError: #{api_error.class_name}::#{api_error.method_name} - #{api_error.exception.message}"
      }
      return retval
  end

end
