import Foundation

public struct Kit {
    
    public enum CryptoKitError: Error {
        case signFailed
        case noEnoughSpace
    }

    public static func ecdhAgree(privateKey: Data, withPublicKey publicKey: Data) -> Data {
        let sharedSecretPtr: UnsafeMutablePointer<UInt8> = _ECDH.agree(privateKey, withPublicKey: publicKey)
        return Data(buffer: UnsafeBufferPointer(start: sharedSecretPtr, count: 32))
    }
    
    public static func sha256(_ data: Data) -> Data {
        _Hash.sha256(data)
    }
    
    public static func sha256sha256(_ data: Data) -> Data {
        sha256(sha256(data))
    }

    public static func sha3(_ data: Data) -> Data {
        Sha3.keccak256(data)
    }
    
    public static func ripemd160(_ data: Data) -> Data {
        _Hash.ripemd160(data)
    }
    
    public static func sha256ripemd160(_ data: Data) -> Data {
        ripemd160(sha256(data))
    }
    
    public static func hmacsha512(data: Data, key: Data) -> Data {
        _Hash.hmacsha512(data, key: key)
    }

    public static func scrypt(pass: Data) -> Data {
        precondition(!pass.isEmpty)

        return _Hash.scrypt(pass)
    }

    public static func deriveKey(password: Data, salt: Data, iterations: Int, keyLength: Int) -> Data {
        _Key.deriveKey(password, salt: salt, iterations: iterations, keyLength: keyLength)
    }
    
    public static func derivedHDKey(hdKey: HDKey, at: UInt32, hardened: Bool) -> HDKey? {
        let key = _HDKey(privateKey: hdKey.privateKey, publicKey: hdKey.publicKey, chainCode: hdKey.chainCode, depth: hdKey.depth, fingerprint: hdKey.fingerprint, childIndex: hdKey.childIndex)
        
        if let derivedKey = key.derived(at: at, hardened: hardened) {
            return HDKey(privateKey: derivedKey.privateKey, publicKey: derivedKey.publicKey, chainCode: derivedKey.chainCode, depth: derivedKey.depth, fingerprint: derivedKey.fingerprint, childIndex: derivedKey.childIndex)
        }
        
        return nil
    }

}

public struct HDKey {
    public let privateKey: Data?
    public let publicKey: Data?
    public let chainCode: Data
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    
    public init(privateKey: Data?, publicKey: Data?, chainCode: Data, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }
}
