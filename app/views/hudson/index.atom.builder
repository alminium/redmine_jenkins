atom_feed(:language => User.current.language,
          :root_url => @site_url,
          :url      => @atom_url,
          :id       => @site_url) do |feed|
  f_title = "#{@project || Setting.app_title}: #{l(:label_hudson_plural)}"        
  feed.title    truncate_single_line(f_title, :length => 100)
  feed.subtitle @site_description
  feed.updated  Time.now
  feed.author{|author| author.name(Setting.app_title) }

  all_builds = []
  @hudson.jobs.each do |job|
    next unless @hudson.settings.job_include?(job.name)
    builds = job.fetch_recent_builds
    builds.each do |build|
      all_builds.push(build)
    end
  end

  @hudson.jobs.each do |job|
    next unless @hudson.settings.job_include?(job.name)
    title = "#{job.name}"
    title += " ##{job.latest_build_number} (#{job.latest_build.result})" if job.latest_build_number
    title += " (#{l(:notice_no_builds)})" unless job.latest_build_number
    content = generate_atom_content(job) 
    feed.entry(job,
                 :url       => job.url_for(:user),
                 :id        => job.id,
                 :published => job.created_at,
                 :updated   => job.updated_at
                 ) do |item|
        item.title(title)
        item.content(content, :type => 'html')
    end
  end
end
