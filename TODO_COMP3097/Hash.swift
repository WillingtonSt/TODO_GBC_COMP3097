//
//  Hash.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//

import CommonCrypto
import CryptoKit
import Security
import Foundation


func hashPassword(_ password: String, salt: Data) -> String {
    let combinedData = password.data(using: .utf8)! + salt
    let hashed = SHA256.hash(data: combinedData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}

func generateSalt() -> Data {
    var salt = Data(count: 16)
    _ = salt.withUnsafeMutableBytes {
        SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!)
    }
    return salt
}

