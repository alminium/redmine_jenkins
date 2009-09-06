# $Id$

class Hudson
  unloadable

  attr_accessor :project_id, :settings, :jobs

  def initialize(project_id)
    @project_id = project_id
    @settings = HudsonSettings.find_by_project_id(@project_id)
    @jobs = HudsonJob.find :all,
                           :order => "#{HudsonJob.table_name}.name",
                           :conditions => ["#{HudsonJob.table_name}.project_id = ?", @project_id]
  end

  def get_job(job_name)
      job = @jobs.find{|job| job.name == job_name }
      return job
  end

  def new_job(job_name)
      retval = HudsonJob.new
      retval.name = job_name
      retval.project_id = @project_id
      retval.hudson_id = @settings.id
      @jobs << retval
      return retval
  end

  def open( uri )
    param = URI.parse( URI.escape(uri) )

    getpath = param.path
    getpath += "?" + param.query if param.query != nil && param.query.length > 0

    request = Net::HTTP::Get.new(getpath)
    request.basic_auth(@settings.auth_user, @settings.auth_password) if @settings.use_authentication?

    if "https" == param.scheme then
      param.port = 443 if param.port == nil || param.port = ""
    end

    http = Net::HTTP.new(param.host, param.port)
    if "https" == param.scheme then
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    begin
      response = http.request(request)
    rescue Net::HTTPBadResponse => error
      raise HudsonHttpException.new(error)
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT => error
      raise HudsonHttpException.new(error)
    rescue URI::InvalidURIError => error
      raise HudsonHttpException.new(error)
    end

    case response
    when Net::HTTPSuccess, Net::HTTPFound
      return response.body
    else
      raise HudsonHttpException.new(response)
    end
  end

end

def Hudson.find_by_project_id(project_id)
  retval = Hudson.new(project_id)
  return retval
end
