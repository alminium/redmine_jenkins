group :redmine_hudson_test do
  gem 'rspec', :require => false, :group => :development
  gem "rspec-rails", ">= 2.3.0", :group => :development
  gem 'cucumber', :group => :development
  gem 'cucumber-rails', :require => false, :group => :development
  gem 'capybara', :require => false, :group => :development
  gem 'selenium-webdriver', :require => false, :group => :development
  gem 'database_cleaner', :require => false, :group => :development

  gem 'mocha', "=0.12.3", :require => false
  
  platforms :mri_18, :mingw_18 do
    gem "rcov", :group => :development
  end

  platforms :mri_19, :mingw_19 do
    gem 'simplecov', :require => false, :group => :development
    gem 'simplecov-rcov', :require => false, :group => :development
    gem 'simplecov-rcov-text', :require => false, :group => :development
  end
end

