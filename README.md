# Pokemon Challenge App
![Xcode](https://img.shields.io/badge/Xcode-11.2-blue.svg) ![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg) ![min iOS](https://img.shields.io/badge/min%20iOS-13.2-lightgrey.svg)


## Getting Started
If you are ready to play with the project just open `PokemonChallenge.xcworkspace`. :rocket:

### Installing

Before open the project and build run the following command to install all the code dependencies:
```bash
pod install
swift package update
```

## Development
For this project I use [VIPER](https://www.objc.io/issues/13-architecture/viper/) as the architecture, it's important to understand this concept:

- **Modules**: UI based modules are defined by VIPER as anything that contains a View. Only create these using the Xcode Template.
- **Services**: Usually each class is made to serve to a single purpose, e.g. Database, Networking, Logging. Create these in the Services folder and name as **<purpose\>Service**.
- **Design System**: UI elements, similar to Services, only have one purpose, but it's related to UI, e.g. Button, Icon. Create these in the Design System folder.

More tips on VIPER can be found [here](https://theswiftdev.com/2018/03/12/the-ultimate-viper-architecture-tutorial/).

**VIPER Diagram**

![diagram](https://i.imgur.com/YHOzL9s.png)

## Testing

All the tests runs on a iPhone 11 (13.2).

UI Tests are created on using Gherkin language and is stored on `PokemonChallengeUITests/features` folder

A 3rd party library [Capriccio](https://github.com/shibapm/capriccio) generates the Swift code using this [template](https://github.com/mydrive/ios-mydrive-app/blob/dev/Templates/Capriccio/Gherkin.stencil) to generate the steps.

Greate article about [Gherkin language](https://automationpanda.com/2017/01/30/bdd-101-writing-good-gherkin/)

## Decisions

- **Cocoapods**: The decision to use Cocoapods was because I added 3rd Party dependencies to Tests, such as Quick/Nimble and SnapshotTests. It could be done without Quick/Nimble, but I believe SnapshotTest is a valid test.
- **Swift Package Manager**: In order to support Capriccio I decided to use SPM, also a script was added in `PokemonChallengeUITest` to automatically generate the Gherkin files.
- **User journey**: The perfect journey I defined as _Search -> Select item -> See the details_, this journey is described as one scenario on Gherkin, along with some others.
- **Persistence**: Decided to use CoreData, created a Service to handle CoreData also decided to create another Entitity to avoid to add CoreData to may other parts of the app, using a separate if a choise in the future to migrate to Realm or maybe a new database Apple launches just a change on this Entity, Service, Coordinator and AppDelegate are required, nothing else.