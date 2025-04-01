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
    //convert password to bytes and combine with salt
    let combinedData = password.data(using: .utf8)! + salt
    //hash bytes with the SHA256 algorithm
    let hashed = SHA256.hash(data: combinedData)
    //map each value as 2 digit hexadecimal string and combine all into one string
    return hashed.map { String(format: "%02x", $0) }.joined()
}

//generate random bytes to be used as a salt
func generateSalt() -> Data {
    //create empty data object with 16 bytes
    var salt = Data(count: 16)
    //fill data with 16 random bytes
    _ = salt.withUnsafeMutableBytes {
        SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!)
    }
    return salt
}

