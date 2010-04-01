# $Id: hudson_index.feature 477 2010-03-27 16:45:28Z toshiyuki.ando1971 $
Feature: issue
  show hudson build results on issue

  Scenario: Show job simple-ruby-application
    Given Project "eCookbook" uses "hudson" Plugin
      And "Developer" has a permission "view_hudson,edit_hudson_settings"
      And I log on as a User
      And I select "English" as language
      And I join "eCookbook" Project as a "Developer"
      And "eCookbook" Project Has Hudson Jobs:
        | name                    |
        | simple-ruby-application |
      And Hudson Job "simple-ruby-application" Has Hudson Build Results:
        | number | result  | finished_at | building | error | caused_by | revisions |
        | 5      | SUCCESS | #today      | false    |       | 1         | 2         |
      And Issue #1 is related to revisions "2"
    When I show issue #1
    Then I should see "new RevisionBuildResults('2');"
     And I should see "BuildResult('simple-ruby-application',5,'SUCCESS'"
     And I should see ",'http://redmine.local/hudson/job/simple-ruby-application/5'));"
