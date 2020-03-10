// Copyright © 2017-2018 Trust.
//
// This test was copied from TrustKeystore and modified by adding tests for litecoin block headers.
//The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

@testable import OpenSslKit
import XCTest

class ScryptTests: XCTestCase {

    func testBlockHeader() {
        let datas = [
            "020000004c1271c211717198227392b029a64a7971931d351b387bb80db027f270411e398a07046f7d4a08dd815412a8712f874a7ebf0507e3878bd24e20a3b73fd750a667d2f451eac7471b00de6659", 
            "0200000011503ee6a855e900c00cfdd98f5f55fffeaee9b6bf55bea9b852d9de2ce35828e204eef76acfd36949ae56d1fbe81c1ac9c0209e6331ad56414f9072506a77f8c6faf551eac7471b00389d01", 
            "02000000a72c8a177f523946f42f22c3e86b8023221b4105e8007e59e81f6beb013e29aaf635295cb9ac966213fb56e046dc71df5b3f7f67ceaeab24038e743f883aff1aaafaf551eac7471b0166249b", 
            "010000007824bc3a8a1b4628485eee3024abd8626721f7f870f8ad4d2f33a27155167f6a4009d1285049603888fe85a84b6c803a53305a8d497965a5e896e1a00568359589faf551eac7471b0065434e", 
            "0200000050bfd4e4a307a8cb6ef4aef69abc5c0f2d579648bd80d7733e1ccc3fbc90ed664a7f74006cb11bde87785f229ecd366c2d4e44432832580e0608c579e4cb76f383f7f551eac7471b00c36982"
        ]
        let expectedResults = [
            "065898d7ab2daa8235cdda9511d248f3010b5e11f682f80741ef2b0000000000",
            "94fc881c9ff1da50d235ed28f2bbcfddfeb7084e63ebd5bd110d3a0000000000",
            "81caa81451ddf8659cf2afd8599d2d6c8a724432e188f295f8400b0000000000",
            "fe05e1971818866adc7e8e6e2fd7e8d8991e032349cd91580007300000000000",
            "8cec00384d72c7e74f5b340d73af02fa47cb0c13c7afa426b4f0180000000000"
        ]

        datas.enumerated().forEach { index, string in
            let data = Data(hexString: string)!
            let expected = Data(hexString: expectedResults[index])!

            let actual = Kit.scrypt(pass: data)
            XCTAssertEqual(actual, expected)
        }
    }
    
    func testMeasure() {
        let data = Data(hexString: "020000004c1271c211717198227392b029a64a7971931d351b387bb80db027f270411e398a07046f7d4a08dd815412a8712f874a7ebf0507e3878bd24e20a3b73fd750a667d2f451eac7471b00de6659")!
        let expected = Data(hexString: "065898d7ab2daa8235cdda9511d248f3010b5e11f682f80741ef2b0000000000")!
        
        self.measure {
            let actual = Kit.scrypt(pass: data)
            XCTAssertEqual(actual, expected)
        }
    }

}
