//
//  PokemonCardSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 24/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick
import SnapshotTesting
import SnapshotTesting_Nimble

class PokemonCardSpec: QuickSpec {
    let cardSize = 132
    let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!
    let shiny =  UIImage(named: "bulbasaur_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!
    
    override func spec() {
        describe("PokemonCardSpec") {
            beforeSuite {
                // Snapshots must be compared using a simulator with the same OS, device as the simulator that originally took the reference
                self.verifyDevice()
            }
            it("snapshot pokemon card default") {
                let card = PokemonCard()
                card.shinySwitch.isOn = false
                card.image = self.image
                card.shiny = self.shiny
                card.titleLabel.text = "Bulbasaur"

                record = false
                expect(card).to(haveValidSnapshot(as: .image(size: CGSize(width: self.cardSize, height: self.cardSize + 80)), named: "\(self.cardSize)x\(self.cardSize + 80)"))
            }
            
            it("snapshot pokemon card shiny") {
                let card = PokemonCard()
                card.shinySwitch.isOn = true
                card.image = self.image
                card.shiny = self.shiny
                card.titleLabel.text = "Bulbasaur"

                record = false
                expect(card).to(haveValidSnapshot(as: .image(size: CGSize(width: self.cardSize, height: self.cardSize + 80)), named: "\(self.cardSize)x\(self.cardSize + 80)"))
            }
        }
    }
}
