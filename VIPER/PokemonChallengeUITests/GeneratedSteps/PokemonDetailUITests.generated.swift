/**
    This code is autogenerated using Capriccio 1.1.0 - https://github.com/shibapm/capriccio
    Implement the missing code in a extension, i.e.

    ```
    extension XCTestCase {
        func step<step name>() {}
    }
    ```

    DO NOT EDIT
*/
import XCTest

/**
Feature:
    Pokemon detail screen
*/

class PokemonDetailScreenFeatureTest: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
      
    func testScenario_UserCanSeeTheDetailOfPokemon_AvailableAndCanAndHas() {
        launchScenarioUserCanSeeTheDetailOfPokemon(with: "AvailableAndCanAndHas")
        stepUserIsOnThePokemonDetailScreen()
        stepUserNetworkAndPersistentItensAre(availableOrNot: "available", hasOrNot: "has")
        stepUserSeeThePokedexEntries(canOrNot: "can")
    } 
    func testScenario_UserCanSeeTheDetailOfPokemon_NotAvailableAndCanAndHas() {
        launchScenarioUserCanSeeTheDetailOfPokemon(with: "NotAvailableAndCanAndHas")
        stepUserIsOnThePokemonDetailScreen()
        stepUserNetworkAndPersistentItensAre(availableOrNot: "not available", hasOrNot: "has")
        stepUserSeeThePokedexEntries(canOrNot: "can")
    } 
    func testScenario_UserCanSeeTheDetailOfPokemon_AvailableAndCanAndHasNot() {
        launchScenarioUserCanSeeTheDetailOfPokemon(with: "AvailableAndCanAndHasNot")
        stepUserIsOnThePokemonDetailScreen()
        stepUserNetworkAndPersistentItensAre(availableOrNot: "available", hasOrNot: "has not")
        stepUserSeeThePokedexEntries(canOrNot: "can")
    } 
    func testScenario_UserCanSeeTheDetailOfPokemon_NotAvailableAndCannotAndHasNot() {
        launchScenarioUserCanSeeTheDetailOfPokemon(with: "NotAvailableAndCannotAndHasNot")
        stepUserIsOnThePokemonDetailScreen()
        stepUserNetworkAndPersistentItensAre(availableOrNot: "not available", hasOrNot: "has not")
        stepUserSeeThePokedexEntries(canOrNot: "cannot")
    }    
    func testScenario_UserCanSeeADetailOfAShinyPokemon() {
        launchScenarioUserCanSeeADetailOfAShinyPokemon()
        stepUserIsOnThePokemonDetailScreenOfAShinyPokemon()
        stepUserCanSeeAShinyImageAndShinyOnTheTitle()
    } 
}
