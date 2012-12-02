Feature: Show and Edit Hudson Job Settings

  Background: 
    Given Project "eCookbook" uses "Hudson" Plugin
     And  "Developer" has a permission below:
        | permissions         |
        | View Hudson         |
        | Edit Hudson settings|
     And  I am logged in as "dlopper" with password "foo"
     And  HudsonApi.get_joblist returns "simple-ruby-application_fetch-job_depth0"
    When  I go to HudsonSettings at "eCookbook" Project
    Then  I should see "Settings"

  Scenario: User can see hudson job settings.
    When  I fill in "http://localhost:8080" for "settings[url]"
     And  I click "Save"
    Then  I should see job settings:
        | Enable | Name                    | Num of Builds | Delete Old Build | Days To Keep | Num To Keep | Delete |
        | false  | simple-ruby-application | 0             |                  |              |             |        |

  @current
  Scenario: User can edit hudson job settings.
    When  I fill in "http://localhost:8080" for "settings[url]"
     And  I click "Save"
    When  I check "settings_jobs_simple-ruby-application"
     And  I click "Save"
    Then  I should see job settings:
        | Enable  | Name                    | Num of Builds | Delete Old Build | Days To Keep | Num To Keep | Delete |
        | true    | simple-ruby-application | 0             | false            |              |             |        |
    When  I fill in job settings:
         | Name                    | Enable | Delete Old Build | Days To Keep | Num To Keep |
         | simple-ruby-application | true   | true             | 5            | 100         |
     And  I click "Save"
    Then  I should see job settings:
        | Enable  | Name                    | Num of Builds | Delete Old Build | Days To Keep | Num To Keep | Delete |
        | true    | simple-ruby-application | 0             | true             | 5            | 100         | Delete |
