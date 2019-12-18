Feature: Search a Pokemon

  @ios @android
  Scenario: User can search a Pokemon
    Given User is on the Pokemon List screen
    When User searches for an existent Pokemon
    Then User can see a list with only this Pokemon

  @ios @android
  Scenario: User sees an empty list if search for an inexistent Pokemon
    Given User is on the Pokemon List screen
    When User searches for an inexistent Pokemon
    Then User sees an empty list

  @ios @android
  Scenario: User can see a detail of a search Pokemon
    Given User is on the Pokemon List screen
    When User searches for an existent Pokemon
    Then User clicks on a pokemon on the list
    And User is on the Pokemon Detail screen

  @ios @android
  Scenario: User can see a detail of a search shiny Pokemon
    Given User is on the Pokemon List screen
    When User searches for an existent Pokemon
    Then User clicks on the switch
    And User clicks on a pokemon on the list
    And User is on the Pokemon Detail screen of a shiny pokemon
