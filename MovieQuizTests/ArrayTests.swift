//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 27.01.2026.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTest {
    func testGetValueInRange() throws {
     let array = [1, 2, 3, 4, 5]
     let value = array[safe: 2]
     XCTAssertNotNil(value)
     XCTAssertEqual(value, 2)
        
    }
    
    func testGetValueOutOfRange() throws {
    let array = [1, 2, 3, 4, 5]
        let value = array[safe: 20]
        XCTAssertNil(value)
        
    }
}
