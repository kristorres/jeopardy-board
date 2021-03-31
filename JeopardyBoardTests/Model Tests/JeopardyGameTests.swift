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
            forResource: "game_with_incorrect_category_count",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.incorrectCategoryCount(let count) {
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
            forResource: "game_with_empty_category_title",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.emptyCategoryTitle(let index) {
            errorIsCaught = true
            XCTAssertEqual(index, 3)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testIncorrectClueCount() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "game_with_incorrect_clue_count",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.incorrectClueCount(
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
            forResource: "game_with_multiple_daily_doubles_in_category",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.multipleDailyDoublesInCategory(
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
            forResource: "game_with_incorrect_point_value",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.incorrectPointValue(
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
            forResource: "game_with_empty_answer",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.emptyAnswer(
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
            forResource: "game_with_empty_correct_response",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.emptyCorrectResponse(
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
            forResource: "game_with_incorrect_daily_double_count",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.incorrectDailyDoubleCount(
            let dailyDoubleCount
        ) {
            errorIsCaught = true
            XCTAssertEqual(dailyDoubleCount, 3)
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyFinalJeopardyCategoryTitle() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "game_with_empty_final_jeopardy_category_title",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.emptyFinalJeopardyCategoryTitle {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyFinalJeopardyAnswer() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "game_with_empty_final_jeopardy_answer",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.emptyFinalJeopardyAnswer {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testEmptyFinalJeopardyCorrectResponse() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "game_with_empty_final_jeopardy_correct_response",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        var errorIsCaught = false
        do {
            let _ = try decoder.decode(JeopardyGame.self, from: jsonData)
        }
        catch JeopardyGame.ValidationError.emptyFinalJeopardyCorrectResponse {
            errorIsCaught = true
        }
        catch {
        }
        XCTAssertTrue(errorIsCaught)
    }
    
    func testValidGame() {
        let bundle = Bundle(for: type(of: self))
        let jsonURL = bundle.url(
            forResource: "game_2021-01-08",
            withExtension: "json"
        )!
        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        let game = try! decoder.decode(JeopardyGame.self, from: jsonData)
        XCTAssertEqual(game.jeopardyRoundCategories.count, 6)
        XCTAssertEqual(game.currentRound, .jeopardy)
        XCTAssertNil(game.dailyDoubleWager)
    }
}
