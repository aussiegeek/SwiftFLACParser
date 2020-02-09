import SwiftFLACParser
import XCTest
import Path

enum SwiftFLACParserTestsError: Error {
    case errorFetchingTestPath
}
final class SwiftFLACParserTests: XCTestCase {
    func samplePath(filename: String) throws -> String {
        guard let testPath = Path(#file) else {
            XCTFail("Failure fetching test path")
            throw SwiftFLACParserTestsError.errorFetchingTestPath
        }

        return testPath.parent.parent.parent.join("samples").join(filename).string
    }
    func testMetadata() throws {
        let filePath = try samplePath(filename: "bitter_words.flac")

        print(filePath)
        let file = try SwiftFLACParser(filename: filePath)
        let title = file.metadata["TITLE"]
        XCTAssertEqual(title, "Bitter Words")

        // Check the correct number of metadata elements were retrieved
        XCTAssertEqual(file.metadata.count, 43)
    }

    func testInvalidFile() {
        XCTAssertThrowsError(try SwiftFLACParser(filename: "/ireallydontexist"), "nope") { error in
            XCTAssertEqual(error as? SwiftFLACParserError, SwiftFLACParserError.errorOpeningFile)
        }
    }
}
