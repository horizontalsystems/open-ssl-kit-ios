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
            "00000000002bef4107f882f6115e0b01f348d21195dacd3582aa2dabd7985806",
            "00000000003a0d11bdd5eb634e08b7feddcfbbf228ed35d250daf19f1c88fc94", 
            "00000000000b40f895f288e13244728a6c2d9d59d8aff29c65f8dd5114a8ca81", 
            "00000000003007005891cd4923031e99d8e8d72f6e8e7edc6a86181897e105fe", 
            "000000000018f0b426a4afc7130ccb47fa02af730d345b4fe7c7724d3800ec8c"
        ]


        var params = ScryptParams()
        params.n = 1024
        params.r = 1
        params.p = 1
        params.desiredKeyLength = 32


        datas.enumerated().forEach { index, string in
            let data = Data(hexString: string)!
            let expected = Data(hexString: expectedResults[index])!

            params.salt = data

            let scrypt = Scrypt(params: params)
            let actual = try! scrypt.calculate(data: data)

            XCTAssertEqual(actual, expected)
        }
    }

    func testCase1() {

        var params = ScryptParams()
        params.n = 1024
        params.r = 8
        params.p = 16
        params.desiredKeyLength = 64

        params.salt = "NaCl".data(using: .utf8)!

        let scrypt = Scrypt(params: params)
        let actual = try! scrypt.calculate(password: "password")

        let expected = Data(hexString: "fdbabe1c9d3472007856e7190d01e9fe7c6ad7cbc8237830e77376634b3731622eaf30d92e22a3886ff109279d9830dac727afb94a83ee6d8360cbdfa2cc0640")
        XCTAssertEqual(actual, expected)
    }

    func testCase2() {
        var params = ScryptParams()
        params.n = 16384
        params.r = 8
        params.p = 1
        params.desiredKeyLength = 64
        params.salt = "SodiumChloride".data(using: .utf8)!

        let scrypt = Scrypt(params: params)
        let actual = try! scrypt.calculate(password: "pleaseletmein")

        let expected = Data(hexString: "7023bdcb3afd7348461c06cd81fd38ebfda8fbba904f8e3ea9b543f6545da1f2d5432955613f0fcf62d49705242a9af9e61e85dc0d651e40dfcf017b45575887")
        XCTAssertEqual(actual, expected)
    }

    func testCase3() {
        var params = ScryptParams()
        params.n = 262144
        params.r = 1
        params.p = 8
        params.desiredKeyLength = 32
        params.salt = Data(hexString: "ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19")!

        let scrypt = Scrypt(params: params)
        let actual = try! scrypt.calculate(password: "testpassword")

        let expected = "fac192ceb5fd772906bea3e118a69e8bbb5cc24229e20d8766fd298291bba6bd"
        XCTAssertEqual(actual.hexString, expected)
    }

    func testInvalidDesiredKeyLength() {
        #if (arch(x86_64) || arch(arm64))
        let dklen = ((1 << 32) - 1) * 32 + 1
        XCTAssertThrowsError(try ScryptParams(salt: Data(), n: 1024, r: 1, p: 1, desiredKeyLength: dklen)) { error in
            if case ScryptParams.ValidationError.desiredKeyLengthTooLarge = error {} else {
                XCTFail("Invalid error generated: \(error)")
            }
        }
        #endif
    }

    func testZeroCostInvalid() {
        XCTAssertThrowsError(try ScryptParams(salt: Data(), n: 0, r: 1, p: 1, desiredKeyLength: 64)) { error in
            if case ScryptParams.ValidationError.invalidCostFactor = error {} else {
                XCTFail("Invalid error generated: \(error)")
            }
        }
    }

    func testOddCostInvalid() {
        XCTAssertThrowsError(try ScryptParams(salt: Data(), n: 3, r: 1, p: 1, desiredKeyLength: 64)) { error in
            if case ScryptParams.ValidationError.invalidCostFactor = error {} else {
                XCTFail("Invalid error generated: \(error)")
            }
        }
    }

    func testLargeCostInvalid() {
        XCTAssertThrowsError(try ScryptParams(salt: Data(), n: Int.max / 128, r: 8, p: 1, desiredKeyLength: 64)) { error in
            if case ScryptParams.ValidationError.invalidCostFactor = error {} else {
                XCTFail("Invalid error generated: \(error)")
            }
        }
    }

    func testLargeBlockSizeInvalid() {
        #if (arch(x86_64) || arch(arm64))
        XCTAssertThrowsError(try ScryptParams(salt: Data(), n: 1024, r: Int.max / 128 + 1, p: 1, desiredKeyLength: 64)) { error in
            if case ScryptParams.ValidationError.blockSizeTooLarge = error {} else {
                XCTFail("Invalid error generated: \(error)")
            }
        }
        #endif
    }

}
