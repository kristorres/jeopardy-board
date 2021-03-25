import XCTest
@testable import JeopardyBoard

final class ClueTests: XCTestCase {
    
    private let answer = "This is the answer."
    private let correctResponse = "What is the correct response?"
    
    func testRegularClue() {
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
    
    func testFinalJeopardyClue() {
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
    
    func testNegativePointValue() {
        let jsonData = """
        {
            "pointValue": -200,
            "answer": "\(answer)",
            "correctResponse": "\(correctResponse)",
            "isDailyDouble": false,
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.Clue.self, from: jsonData)
        }
        catch JeopardyGame.APIError.invalidPointValue(let pointValue) {
            XCTAssertEqual(pointValue, -200)
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testZeroPointValue() {
        let jsonData = """
        {
            "pointValue": 0,
            "answer": "\(answer)",
            "correctResponse": "\(correctResponse)",
            "isDailyDouble": false,
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.Clue.self, from: jsonData)
        }
        catch JeopardyGame.APIError.invalidPointValue(let pointValue) {
            XCTAssertEqual(pointValue, 0)
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testMissingDailyDoublePointValue() {
        let jsonData = """
        {
            "answer": "\(answer)",
            "correctResponse": "\(correctResponse)",
            "isDailyDouble": true,
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.Clue.self, from: jsonData)
        }
        catch JeopardyGame.APIError.missingDailyDoublePointValue {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyAnswer() {
        let jsonData = """
        {
            "pointValue": 200,
            "answer": "",
            "correctResponse": "\(correctResponse)",
            "isDailyDouble": false,
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.Clue.self, from: jsonData)
        }
        catch JeopardyGame.APIError.emptyAnswer {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyCorrectResponse() {
        let jsonData = """
        {
            "pointValue": 200,
            "answer": "\(answer)",
            "correctResponse": "",
            "isDailyDouble": false,
            "isDone": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.Clue.self, from: jsonData)
        }
        catch JeopardyGame.APIError.emptyCorrectResponse {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
}
