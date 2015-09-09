// JWTDecode.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

public func decode(jwt: String) throws -> JWT {
    return try DecodedJWT(jwt: jwt)
}

public protocol JWT {
    var header: [String: AnyObject] { get }
    var body: [String: AnyObject] { get }
    var signature: String? { get }

    var expiresAt: NSDate? { get }
    var expired: Bool { get }
}

public extension JWT {
    public func claim<T>(name: String) -> T? {
        return self.body[name] as? T
    }
}

struct DecodedJWT: JWT {

    let header: [String: AnyObject]
    let body: [String: AnyObject]
    let signature: String?

    init(jwt: String) throws {
        let parts = jwt.componentsSeparatedByString(".")
        guard parts.count == 3 else {
            throw errorWithDescription(NSLocalizedString("malformed jwt token \(jwt) only has \(parts.count) parts (3 parts are required)", comment: "Not enough jwt parts"))
        }
        var base64 = parts[1]
            .stringByReplacingOccurrencesOfString("-", withString: "+")
            .stringByReplacingOccurrencesOfString("_", withString: "/")
        let length = Double(base64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".stringByPaddingToLength(Int(paddingLength), withString: "=", startingAtIndex: 0)
            base64 = base64.stringByAppendingString(padding)
        }
        guard let data = NSData(base64EncodedString: base64, options: .IgnoreUnknownCharacters) else {
            throw errorWithDescription(NSLocalizedString("malformed jwt token \(jwt). failed to decode base64 payload", comment: "Invalid base64"))
        }
        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] else {
            throw errorWithDescription(NSLocalizedString("malformed jwt token \(jwt). failed to decode base64 payload", comment: "Invalid base64"))
        }
        self.header = [:]
        self.body = json
        self.signature = parts[2]
    }

    var expiresAt: NSDate? {
        if let exp:Double = claim("exp") {
            return NSDate(timeIntervalSince1970: exp)
        } else {
            return nil
        }
    }

    var expired: Bool {
        guard let date = self.expiresAt else {
            return false
        }
        return date.compare(NSDate()) != NSComparisonResult.OrderedDescending
    }
}

private func errorWithDescription(description: String) -> NSError {
    return NSError(domain: "com.auth0.JWTDecode", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
}