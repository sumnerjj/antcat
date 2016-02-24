Feature: Searching the catalog
  As a user of AntCat
  I want to search the catalog in index view
  So that I can find taxa with their parents and siblings

  Background:
    Given the Formicidae family exists

  Scenario: Searching when not logged in
    When I go to the catalog
    And I follow the first "Advanced Search"
    Then I should be on the advanced search page

  Scenario: Searching when no results
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "No results"

  Scenario: Searching when one result
    Given there is a species described in 2010
    And there is a species described in 2011
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see the species described in 2010

  Scenario: Searching for subfamilies
    Given there is a subfamily described in 2010
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I select "Subfamilies" from the rank selector
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see the species described in 2010

  Scenario: Searching for an invalid taxon
    Given there is an invalid species described in 2010
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "year" with "2010"
    And I check "valid_only"
    And I press "Go" in the search section
    Then I should see "No results"

  Scenario: Searching for an author's descriptions
    Given there is a species described in 2010 by "Bolton"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see the species described in 2010

  Scenario: Finding an original combination
    Given there is an original combination of "Atta major" described by "Bolton" which was moved to "Betta major"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "see Betta major"

  Scenario: Finding a genus
    And there is a species "Atta major" with genus "Atta"
    And there is a species "Ophthalmopone major" with genus "Ophthalmopone"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "genus" with "Atta"
    And I press "Go" in the search section
    Then I should see "Atta major"

  Scenario: Finding a junior synonym
    Given there is a species "Atta major" described by "Bolton" which is a junior synonym of "Betta minor"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "synonym of"
    And I should see "Betta minor"

  Scenario: Manually entering an unknown name instead of using picklist
    Given there is a species described in 2010 by "Bolton, B."
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "author_name" with "Bolton"
    And I press "Go" in the search section
    Then I should see "No results found. If you're choosing an author, make sure you pick the name from the dropdown list."

  Scenario: Searching for locality
    Given there is a genus located in "Africa"
    And there is a genus located in "Zimbabwe"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "locality" with "Africa"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "Africa" within ".results_section-test-hook"

  Scenario: Searching for verbatim type locality
    Given there is a species with verbatim type locality "Africa"
    And there is a species with verbatim type locality "Zimbabwe"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "verbatim_type_locality" with "Africa"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "Africa" within ".results_section-test-hook"

  Scenario: Searching for type specimen repository
    Given there is a species with type specimen repository "CZN"
    And there is a species with type specimen repository "IAD"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "type_specimen_repository" with "CZN"
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "CZN" within ".results_section-test-hook"

  Scenario: Searching for type specimen code
    Given there is a species with type specimen code "1234"
    And there is a species with type specimen code "4321"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "type_specimen_code" with "1234"
    And I press "Go" in the search section
    And I wait for a while
    Then I should see "1 result"
    And I should see "1234" within ".results_section-test-hook"

  Scenario: Searching for biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species with biogeographic region "Afrotropic"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I select "Afrotropic" from the biogeographic region selector
    And I press "Go" in the search section
    Then I should see "2 results"
    And I should see "Afrotropic" within ".results_section-test-hook"

  Scenario: Searching for 'Any' biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a genus located in "Africa"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I select "Any" from the biogeographic region selector
    And I fill in "locality" with "Africa"
    And I press "Go" in the search section
    Then I should see "1 result"

  Scenario: Searching for 'None' biogeographic_region
    Given there is a species with biogeographic region "Malagasy"
    And there is a species with biogeographic region "Afrotropic"
    And there is a species located in "Africa"
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I select "Species" from the rank selector
    And I select "None" from the biogeographic region selector
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "Africa" within ".results_section-test-hook"

  Scenario: Searching for a form
    Given there is a species with forms "w.q."
    And there is a species with forms "q."
    When I go to the catalog
    And I follow the first "Advanced Search"
    And I fill in "forms" with "w."
    And I press "Go" in the search section
    Then I should see "1 result"
    And I should see "w." within ".results_section-test-hook"
