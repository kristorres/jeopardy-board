import XCTest
@testable import JeopardyBoard

final class ClueSetTests: XCTestCase {
    
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
        let clue = try! decoder.decode(Clue.self, from: jsonData)
        XCTAssertTrue(clue.id.hasPrefix("CLUE-"))
        XCTAssertEqual(clue.pointValue, 200)
        XCTAssertEqual(clue.answer, answer)
        XCTAssertEqual(clue.correctResponse, correctResponse)
        XCTAssertFalse(clue.isDailyDouble)
        XCTAssertFalse(clue.isSelected)
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
        let category = try! decoder.decode(Category.self, from: jsonData)
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
            .decode(FinalJeopardyClue.self, from: jsonData)
        XCTAssertEqual(finalJeopardyClue.categoryTitle, categoryTitle)
        XCTAssertEqual(finalJeopardyClue.answer, answer)
        XCTAssertEqual(finalJeopardyClue.correctResponse, correctResponse)
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
        let player = try! decoder.decode(Player.self, from: jsonData)
        XCTAssertTrue(player.id.hasPrefix("PLAYER-"))
        XCTAssertEqual(player.name, "James Holzhauer")
        XCTAssertEqual(player.score, 131127)
        XCTAssertTrue(player.canSelectClue)
    }
    
    func testIncorrectCategoryCount() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_incorrect-category-count",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.incorrectCategoryCount(let count) {
            errorIsCaught = true
            XCTAssertEqual(count, 1)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyCategoryTitle() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_empty-category-title",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.emptyCategoryTitle(let categoryIndex) {
            errorIsCaught = true
            XCTAssertEqual(categoryIndex, 3)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testIncorrectClueCount() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_incorrect-clue-count",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.incorrectClueCount(
            let clueCount,
            let categoryIndex
        ) {
            errorIsCaught = true
            XCTAssertEqual(clueCount, 6)
            XCTAssertEqual(categoryIndex, 3)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testMultipleDailyDoublesInCategory() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_multiple-daily-doubles-in-category",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.multipleDailyDoublesInCategory(
            let categoryIndex
        ) {
            errorIsCaught = true
            XCTAssertEqual(categoryIndex, 4)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testIncorrectPointValue() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_incorrect-point-value",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.incorrectPointValue(
            let pointValue,
            let expectedPointValue,
            let categoryIndex,
            let clueIndex
        ) {
            errorIsCaught = true
            XCTAssertEqual(pointValue, 2000)
            XCTAssertEqual(expectedPointValue, 800)
            XCTAssertEqual(categoryIndex, 4)
            XCTAssertEqual(clueIndex, 3)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyAnswer() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_empty-answer",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.emptyAnswer(
            let categoryIndex,
            let clueIndex
        ) {
            errorIsCaught = true
            XCTAssertEqual(categoryIndex, 3)
            XCTAssertEqual(clueIndex, 2)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyCorrectResponse() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_empty-correct-response",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.emptyCorrectResponse(
            let categoryIndex,
            let clueIndex
        ) {
            errorIsCaught = true
            XCTAssertEqual(categoryIndex, 3)
            XCTAssertEqual(clueIndex, 2)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testClueIsDone() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_finished-clue",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.clueIsDone(
            let categoryIndex,
            let clueIndex
        ) {
            errorIsCaught = true
            XCTAssertEqual(categoryIndex, 3)
            XCTAssertEqual(clueIndex, 2)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testIncorrectDailyDoubleCount() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_incorrect-daily-double-count",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.incorrectDailyDoubleCount(let count) {
            errorIsCaught = true
            XCTAssertEqual(count, 3)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyFinalJeopardyCategoryTitle() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_empty-final-jeopardy-category-title",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.emptyFinalJeopardyCategoryTitle {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyFinalJeopardyAnswer() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_empty-final-jeopardy-answer",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.emptyFinalJeopardyAnswer {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyFinalJeopardyCorrectResponse() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_empty-final-jeopardy-correct-response",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(ClueSet.self, from: jsonData)
        }
        catch ClueSet.ValidationError.emptyFinalJeopardyCorrectResponse {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testValidClueSet() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "clue-set_2021-01-08",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        let clueSet = try! decoder.decode(ClueSet.self, from: jsonData)
        XCTAssertEqual(clueSet.jeopardyRoundCategories.count, 6)
    }
}
