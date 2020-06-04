import XCTest
import OpenSslKit

class Tests: XCTestCase {

    func testExample() {
        // This is an example of a functional test case.
        let data = Data(repeating: 1, count: 32)
        let _ = Kit.sha256(data)

        XCTAssert(true)
    }

}
