# $Id$

require 'redmine/version'

module RedmineHudson
  module RedmineExt

    def RedmineExt.redmine_090_or_higher?
      return !(Redmine::VERSION::MAJOR == 0 && Redmine::VERSION::MINOR < 9)
    end

    module QueryPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.send(:include, InstanceMethodsFor09Later) if RedmineHudson::RedmineExt.redmine_090_or_higher?
        base.send(:include, InstanceMethodsFor08) unless RedmineHudson::RedmineExt.redmine_090_or_higher?

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method_chain :available_filters, :redmine_hudson unless method_defined?(:available_filters_without_redmine_hudson)
          alias_method_chain :sql_for_field, :redmine_hudson unless method_defined?(:sql_for_field_without_redmine_hudson)
        end

      end
    end

    module ClassMethods

      unless Query.respond_to?(:available_columns=)
        # Setter for +available_columns+ that isn't provided by the core.
        def available_columns=(v)
          self.available_columns = (v)
        end
      end

      unless Query.respond_to?(:add_available_column)
        # Method to add a column to the +available_columns+ that isn't provided by the core.
        def add_available_column(column)
          self.available_columns << (column)
        end
      end
    end

    module InstanceMethods

      def available_filters_with_redmine_hudson
        return @available_filters if @available_filters

        available_filters_without_redmine_hudson

        return @available_filters unless project

        hudson_filters

        @hudson_filters.each do |filter|
          @available_filters[filter.name] = filter.available_values
        end
        return @available_filters
      end

      def sql_for_hudson_build(field, operator, value)
        return sql_for_always_false unless project

        hudson_changesets = find_hudson_changesets

        return sql_for_issues(hudson_changesets)
      end

      def sql_for_hudson_job(field, operator, value)
        return sql_for_always_false unless project

        if filters.has_key?('hudson_build')
          return sql_for_always_true
        end

        hudson_changesets = find_hudson_changesets

        return sql_for_issues(hudson_changesets)
      end

      def find_hudson_changesets

        retval = []
        find_hudson_jobs.each do |job|
          builds = find_hudson_builds(job)
          next if builds.length == 0
          cond_builds = builds.collect{|build| "#{connection.quote_string(build.id.to_s)}"}.join(",")
          retval += HudsonBuildChangeset.find(:all, :conditions => ["#{HudsonBuildChangeset.table_name}.hudson_build_id in (#{cond_builds})"], :order => "#{HudsonBuildChangeset.table_name}.id DESC", :limit => Hudson.query_limit_changesets_each_job)
        end

        return retval

      end

      def find_hudson_builds(job)
        return [] unless job

        if filters.has_key?('hudson_build')
          cond_builds = conditions_for('hudson_build', operator_for('hudson_build'), values_for('hudson_build'))
        else
          cond_builds = "#{HudsonBuild.table_name}.id > 0" #always true
        end

        return HudsonBuild.find(:all, :conditions => ["#{HudsonBuild.table_name}.hudson_job_id = ? and #{cond_builds}", job.id], :order => "#{HudsonBuild.table_name}.number DESC", :limit => Hudson.query_limit_builds_each_job)
      end

      def find_hudson_jobs
        return [] unless project

        if filters.has_key?('hudson_job')
          cond_jobs = "#{HudsonJob.table_name}.project_id = #{project.id} and #{conditions_for('hudson_job', operator_for('hudson_job'), values_for('hudson_job'))}"
        else
          cond_jobs = "#{HudsonJob.table_name}.project_id = #{project.id}"
        end
        return HudsonJob.find(:all, :conditions => cond_jobs)
      end


      # conditions always true
      def sql_for_always_true
        return "#{Issue.table_name}.id > 0"
      end

      # conditions always false
      def sql_for_always_false
        return "#{Issue.table_name}.id < 0"
      end

      def sql_for_issues(hudson_changesets)

        return sql_for_always_false unless hudson_changesets
        return sql_for_always_false if hudson_changesets.length == 0

        value_revisions = hudson_changesets.collect{|target| "#{connection.quote_string(target.revision.to_s)}"}.join(",")
        sql = "#{Issue.table_name}.id in"
        sql << "(select changesets_issues.issue_id from changesets_issues"
        sql << " where changesets_issues.changeset_id in"
        sql << "  (select #{Changeset.table_name}.id from #{Changeset.table_name}"
        sql << "   where #{Changeset.table_name}.repository_id = #{project.repository.id}"
        sql << "    and   #{Changeset.table_name}.revision in (#{value_revisions})"
        sql << " )"
        sql << ")"
        
        return sql
      end

      def conditions_for(field, operator, value)
        retval = ""

        available_filters
        return retval unless @hudson_filters
        filter = @hudson_filters.detect {|hfilter| hfilter.name == field}
        return retval unless filter
        db_table = filter.db_table
        db_field = filter.db_field

        case operator
        when "="
          retval = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
        when "!"
          retval = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
        when "!*"
          retval = "#{db_table}.#{db_field} IS NULL"
          retval << " OR #{db_table}.#{db_field} = ''"
        when "*"
          retval = "#{db_table}.#{db_field} IS NOT NULL"
          retval << " AND #{db_table}.#{db_field} <> ''"
        when ">="
          retval = "#{db_table}.#{db_field} >= #{value.first.to_i}"
        when "<="
          retval = "#{db_table}.#{db_field} <= #{value.first.to_i}"
        when "!~"
          retval = "#{db_table}.#{db_field} NOT LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
        end
        return retval
      end

      def hudson_filters

        @hudson_filters = []
        return @hudson_filters unless project
        return @hudson_filters unless @available_filters

        hudson = Hudson.find_by_project_id(project.id)
        return @hudson_filters unless hudson

        @hudson_filters << HudsonQueryFilter.new("hudson_job",
                                { :type => :list_optional, :order => @available_filters.size + 1,
                                  :values => HudsonJob.find(:all, :conditions => ["#{HudsonJob.table_name}.project_id = ?", project.id],
                                              :order => "#{HudsonJob.table_name}.name").collect {|job|
                                              next unless hudson.settings.job_include?(job.name)
                                              [job.name, job.id.to_s]
                                            }
                                },
                                HudsonJob.table_name,
                                "id")
        @hudson_filters << HudsonQueryFilter.new("hudson_build",
                                { :type => :integer, :order => @available_filters.size + 2 },
                                HudsonBuild.table_name,
                                "number")

        return @hudson_filters

      end

    end #InstanceMethods

    module InstanceMethodsFor09Later
      def sql_for_field_with_redmine_hudson(field, operator, value, db_table, db_field, is_custom_filter=false)
        case field
        when "hudson_build"
          return sql_for_hudson_build(field, operator, value)

        when "hudson_job"
          return sql_for_hudson_job(field, operator, value)

        else
           return sql_for_field_without_redmine_hudson(field, operator, value, db_table, db_field, is_custom_filter)
        end
      end
    end #InstanceMethodsFor09Later

    module InstanceMethodsFor08
      def sql_for_field_with_redmine_hudson(field, value, db_table, db_field, is_custom_filter)
        operator = operator_for field
        case field
        when "hudson_build"
          return sql_for_hudson_build(field, operator, value)

        when "hudson_job"
          return sql_for_hudson_job(field, operator, value)

        else
           return sql_for_field_without_redmine_hudson(field, value, db_table, db_field, is_custom_filter)
        end
      end
    end #InstanceMethodsFor08

  end #RedmineExt
end #RedmineHudson
