import XCTest
@testable import JeopardyBoard

final class JeopardyGameTests: XCTestCase {
    
    private let categoryTitle = "Category Title"
    private let answer = "This is the answer."
    private let correctResponse = "What is the correct response?"
    
    func testRegularClueDecoding() {
        let jsonData = """
        {
            "pointValue": 200,
            "answer": "\(answer)",
            "correctResponse": "\(correctResponse)",
            "isDailyDouble": false,
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let clue = try! decoder.decode(JeopardyGame.Clue.self, from: jsonData)
        XCTAssertTrue(clue.id.hasPrefix("CLUE-"))
        XCTAssertEqual(clue.pointValue, 200)
        XCTAssertEqual(clue.answer, answer)
        XCTAssertEqual(clue.correctResponse, correctResponse)
        XCTAssertFalse(clue.isDailyDouble)
        XCTAssertFalse(clue.isDone)
    }
    
    func testFinalJeopardyClueDecoding() {
        let jsonData = """
        {
            "answer": "\(answer)",
            "correctResponse": "\(correctResponse)",
            "isDailyDouble": false,
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let clue = try! decoder.decode(JeopardyGame.Clue.self, from: jsonData)
        XCTAssertTrue(clue.id.hasPrefix("CLUE-"))
        XCTAssertNil(clue.pointValue)
        XCTAssertEqual(clue.answer, answer)
        XCTAssertEqual(clue.correctResponse, correctResponse)
        XCTAssertFalse(clue.isDailyDouble)
        XCTAssertFalse(clue.isDone)
    }
    
    func testCategoryDecoding() {
        let jsonData = """
        {
            "title": "\(categoryTitle)",
            "clues": [
                {
                    "pointValue": 200,
                    "answer": "\(answer)",
                    "correctResponse": "\(correctResponse)",
                    "isDailyDouble": false,
                    "isDone": false
                }
            ]
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let category = try! decoder
            .decode(JeopardyGame.Category.self, from: jsonData)
        XCTAssertTrue(category.id.hasPrefix("CATEGORY"))
        XCTAssertEqual(category.title, categoryTitle)
        XCTAssertEqual(category.clues.count, 1)
    }
}
