# $Id$
Feature: index
  show hudson jobs with latest build results

  Scenario: If 'Developer' don't have 'view_hudson' permission, Redmine don't show hudson tab on the menu
    Given Project "eCookbook" uses "hudson" Plugin
      And I log on as a User
      And I select "English" as language
      And I join "eCookbook" Project as a "Developer"

    When I go to "eCookbook" Project

    Then I should not see "Hudson" within "#main-menu"

  Scenario: If 'Developer' have 'view_hudson' permission, Redmine show hudson tab on the menu
    Given Project "eCookbook" uses "hudson" Plugin
      And "Developer" has a permission "view_hudson"
      And I log on as a User
      And I select "English" as language
      And I join "eCookbook" Project as a "Developer"

    When I go to "eCookbook" Project

    Then I should see "Hudson" within "#main-menu"

  Scenario: If project has no Hudson settings, plugin show message
    Given Project "eCookbook" uses "hudson" Plugin
      And "Developer" has a permission "view_hudson"
      And I log on as a User
      And I select "English" as language
      And I join "eCookbook" Project as a "Developer"

   When I go to Hudson at "eCookbook" Project

   Then I should see "No settings for this project. Please confirm settings"