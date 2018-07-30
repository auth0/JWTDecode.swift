// Crypto.swift
//
// Copyright (c) 2018 Auth0 (http://auth0.com)
// Copyright (c) 2015 Henri Normak https://github.com/henrinormak/Heimdall
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import CommonCrypto

extension Data {
    var sha256: Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            self.withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(self.count), digestBytes)
            }
        }
        return digest
    }
}

extension Int {
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)]
        }

        // Long form
        let pos = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(pos + 0x80)]

        for _ in 0..<pos {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }

        return result
    }
}

@available(iOS 10.0, *)
@available(tvOS 10.0, *)
@available(OSX 10.12, *)
func createRSASecKey(modulus: String, exponent: String) -> SecKey? {

    guard let modulusDecoded = base64UrlDecode(modulus), let modulusData = Data(base64Encoded: modulusDecoded) else {
        return nil
    }

    guard let exponentDecoded = base64UrlDecode(exponent), let exponentData = Data(base64Encoded: exponentDecoded) else {
        return nil
    }

    // Make sure neither the modulus nor the exponent start with a null byte
    var modulusBytes = [UInt8](modulusData)
    let exponentBytes = [UInt8](exponentData)

    // Make sure modulus starts with a 0x00
    if let prefix = modulusBytes.first, prefix != 0x00 {
        modulusBytes.insert(0x00, at: 0)
    }

    // Lengths
    let modulusLengthOctets = modulusBytes.count.encodedOctets()
    let exponentLengthOctets = exponentBytes.count.encodedOctets()

    // Total length is the sum of components + types
    let totalLengthOctets = (modulusLengthOctets.count + modulusBytes.count + exponentLengthOctets.count + exponentBytes.count + 2).encodedOctets()

    // Combine the two sets of data into a single container
    var builder: [CUnsignedChar] = []
    let data = NSMutableData()

    // Container type and size
    builder.append(0x30)
    builder.append(contentsOf: totalLengthOctets)
    data.append(builder, length: builder.count)
    builder.removeAll(keepingCapacity: false)

    // Modulus
    builder.append(0x02)
    builder.append(contentsOf: modulusLengthOctets)
    data.append(builder, length: builder.count)
    builder.removeAll(keepingCapacity: false)
    data.append(modulusBytes, length: modulusBytes.count)

    // Exponent
    builder.append(0x02)
    builder.append(contentsOf: exponentLengthOctets)
    data.append(builder, length: builder.count)
    data.append(exponentBytes, length: exponentBytes.count)

    let keySize = (modulus.count * 8)

    let attributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        kSecAttrKeySizeInBits as String: keySize,
        kSecAttrIsPermanent as String: false
    ]

    var error: Unmanaged<CFError>?

    guard let keyReference = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
        print(error ?? "No")
        return nil
    }

    return keyReference
}
