import XCTest
@testable import JeopardyBoard

final class StringTrimmedTests: XCTestCase {
    
    func testPaddedString() {
        XCTAssertEqual("   Hello, world!   ".trimmed, "Hello, world!")
    }
}
