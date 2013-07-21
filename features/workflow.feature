@javascript
Feature: Workflow

  Background:
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And there is a genus "Eciton"
    And version tracking is enabled
    And I log in

  Scenario: Adding a taxon and seeing it on the Changes page
    When I go to the catalog page for "Formicinae"
    And I press "Edit"
    And I press "Add genus"
    And I click the name field
    And I set the name to "Atta"
    And I press "OK"
    And I select "subfamily" from "taxon_incertae_sedis_in"
    And I check "Hong"
    And I fill in "taxon_headline_notes_taxt" with "Notes"
    And I click the protonym name field
    And I set the protonym name to "Eciton"
    And I check "taxon_protonym_attributes_sic"
    And I press "OK"
    And I click the authorship field
    And I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    And I fill in "taxon_protonym_attributes_authorship_attributes_pages" with "260"
    And I fill in "taxon_protonym_attributes_authorship_attributes_forms" with "m."
    And I fill in "taxon_protonym_attributes_locality" with "Africa"
    And I click the type name field
    And I set the type name to "Atta major"
    And I press "OK"
    And I press "Add this name"
    And I check "taxon_type_fossil"
    And I fill in "taxon_type_taxt" with "Type notes"
    And I save my changes
    When I go to the changes page
    Then I should see the name "Atta" in the changes
    And I should see the subfamily "Formicinae" in the changes
    And I should see the status "valid" in the changes
    And I should see the incertae sedis status of "subfamily" in the changes
    And I should see the attribute "Hong" in the changes
    And I should see the notes "Notes" in the changes
    And I should see the protonym name "Eciton" in the changes
    And I should see the protonym attribute "sic" in the changes
    And I should see the authorship reference "Fisher 2004. Ants. Psyche 3:3." in the changes
    And I should see the page "260" in the changes
    And I should see the forms "m." in the changes
    And I should see the locality "Africa" in the changes
    And I should see the type name "Atta major" in the changes
    And I should see the type attribute "Fossil" in the changes
    And I should see the type notes "Type notes" in the changes