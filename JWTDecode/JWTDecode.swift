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

func errorWithDescription(description: String) -> NSError {
    return NSError(domain: "com.auth0.JWTDecode", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
}

public func payload(#jwt: String) -> [String: AnyObject]? {
    return JWTDecoder(jwt: jwt).payloadWithError(nil)
}

public func expired(#jwt: String) -> Bool {
    return JWTDecoder(jwt: jwt).expired
}

public func expiredDate(#jwt: String) -> NSDate? {
    return JWTDecoder(jwt: jwt).expiredDate
}

@objc(A0JWTDecoder)
public class JWTDecoder: NSObject {

    let jwt: String

    public init(jwt: String) {
        self.jwt = jwt
    }

    public func payloadWithError(error: NSErrorPointer) -> [String: AnyObject]? {
        let parts = jwt.componentsSeparatedByString(".")
        if parts.count != 3 {
            if error != nil {
                error.memory = errorWithDescription(NSLocalizedString("malformed jwt token \(jwt) only has \(parts.count) parts (3 parts are required)", comment: "Not enough jwt parts"))
            }
            return nil
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
        if let data = NSData(base64EncodedString: base64, options: .IgnoreUnknownCharacters) {
            return NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: error) as? [String: AnyObject]
        } else {
            if error != nil {
                error.memory = errorWithDescription(NSLocalizedString("malformed jwt token \(jwt). failed to decode base64 payload", comment: "Invalid base64"))
            }
        }
        return nil
    }

    public var expired: Bool {
        if let date = self.expiredDate {
            return date.compare(NSDate()) == .OrderedAscending
        }
        return true
    }

    public var expiredDate: NSDate? {
        if let payload = self.payloadWithError(nil), let exp = payload["exp"] as? Double {
            return NSDate(timeIntervalSince1970: exp)
        }
        return nil
    }

}
