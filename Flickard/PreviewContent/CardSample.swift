import Foundation

extension Card {
    static let sampleData: [Card] = {
        let card1 = Card(front: "Table", back: "der Tisch")
        card1.swipeRight()
        card1.swipeRight()
        card1.swipeLeft()
        card1.swipeRight()
        
        let card2 = Card(front: "Apple", back: "der Apfel")
        card2.swipeRight()
        card2.swipeRight()
        card2.swipeRight()
        
        let card3 = Card(front: "Car", back: "das Auto")
        card3.swipeLeft()
        card3.swipeLeft()
        card3.swipeRight()
        
        let card4 = Card(front: "City", back: "die Stadt")
        card4.swipeLeft()
        card4.swipeLeft()
        card4.swipeLeft()
        card4.swipeLeft()
        
        return [card1, card2, card3, card4]
    }()
}
