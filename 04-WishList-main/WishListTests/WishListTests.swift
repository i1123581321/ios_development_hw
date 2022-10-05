//
//  WishListTests.swift
//  WishListTests
//
//  Created by 钱正轩 on 2020/11/2.
//

import XCTest
@testable import WishList

class WishListTests: XCTestCase {
    
    //MARK: Item Class Tests
    
    func testItemInitializationSucceeds() {
        let zeroRatingItem = Item.init(name: "Zero", photo: nil, rating: 0)
        XCTAssertNotNil(zeroRatingItem)
        
        let positiveRatingItem = Item.init(name: "Positive", photo: nil, rating: 5)
        XCTAssertNotNil(positiveRatingItem)
    }
    
    func testItemInitializationFails() {
        let negativeRatingItem = Item.init(name: "Negative", photo: nil, rating: -1)
        XCTAssertNil(negativeRatingItem)
        
        let largeRatingItem = Item.init(name: "Large", photo: nil, rating: 6)
        XCTAssertNil(largeRatingItem)
        
        let emptyStringItem = Item.init(name: "", photo: nil, rating: 0)
        XCTAssertNil(emptyStringItem)
    }

}
