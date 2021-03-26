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
        XCTAssertTrue(category.id.hasPrefix("CATEGORY-"))
        XCTAssertEqual(category.title, categoryTitle)
        XCTAssertEqual(category.clues.count, 1)
    }
    
    func testFinalJeopardyClueDecoding() {
        let jsonData = """
        {
            "categoryTitle": "\(categoryTitle)",
            "answer": "\(answer)",
            "correctResponse": "\(correctResponse)",
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let finalJeopardyClue = try! decoder
            .decode(JeopardyGame.FinalJeopardyClue.self, from: jsonData)
        XCTAssertEqual(finalJeopardyClue.categoryTitle, categoryTitle)
        XCTAssertEqual(finalJeopardyClue.answer, answer)
        XCTAssertEqual(finalJeopardyClue.correctResponse, correctResponse)
        XCTAssertFalse(finalJeopardyClue.isDone)
    }
    
    func testPlayerDecoding() {
        let jsonData = """
        {
            "name": "James Holzhauer",
            "score": 131127,
            "canSelectClue": true
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let player = try! decoder.decode(JeopardyGame.Player.self, from: jsonData)
        XCTAssertTrue(player.id.hasPrefix("PLAYER-"))
        XCTAssertEqual(player.name, "James Holzhauer")
        XCTAssertEqual(player.score, 131127)
        XCTAssertTrue(player.canSelectClue)
    }
}
