import XCTest
@testable import JeopardyBoard

final class ArrayFirstIndexTests: XCTestCase {
    
    func testEmptyArray() {
        XCTAssertNil([Int]().firstIndex(matching: 0))
    }
    
    func testArrayWithUniqueItems() {
        XCTAssertEqual([4, 6, 7, 9, 12].firstIndex(matching: 7), 2)
    }
    
    func testArrayWithDuplicateItems() {
        XCTAssertEqual([5, 12, 8, 44, 44].firstIndex(matching: 44), 3)
    }
    
    func testFirstIndexOfNonexistentItem() {
        XCTAssertNil([4, 6, 8, 9, 12].firstIndex(matching: 7))
    }
}

extension Int: Identifiable {
    public var id: Int {
        self
    }
}
