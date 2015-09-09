// JWTHelper.swift
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
import JWTDecode

func jwtWithBody(body: [String: AnyObject]) -> JWT {
    var jwt: String = ""
    do {
        let data = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
        let base64 = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
            .stringByReplacingOccurrencesOfString("+", withString: "-")
            .stringByReplacingOccurrencesOfString("/", withString: "_")
            .stringByReplacingOccurrencesOfString("=", withString: "")
        jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(base64).SIGNATURE"
    } catch _ {
        NSException(name: NSInvalidArgumentException, reason: "Failed to build jwt", userInfo: nil).raise()
    }
    return try! decode(jwt)
}

func jwtThatExpiresAt(date: NSDate) -> JWT {
    return jwtWithBody(["exp": date.timeIntervalSince1970])
}

func expiredJWT() -> JWT {
    let seconds = Int(arc4random_uniform(60) + 1) * -1
    let date = NSCalendar.currentCalendar().dateByAddingUnit(.Second, value: seconds, toDate: NSDate(), options: NSCalendarOptions())
    return jwtThatExpiresAt(date!)
}

func nonExpiredJWT() -> JWT {
    let hours = Int(arc4random_uniform(200) + 1)
    let date = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: hours, toDate: NSDate(), options: NSCalendarOptions())
    return jwtThatExpiresAt(date!)
}

class JWTHelper: NSObject {

    class func newJWTWithBody(body: [String: AnyObject]) -> JWT {
        return jwtWithBody(body)
    }

    class func newJWTThatExpiresAt(date: NSDate) -> JWT {
        return jwtThatExpiresAt(date)
    }

    class func newExpiredJWT() -> JWT {
        return expiredJWT()
    }

    class func newNonExpiredJWT() -> JWT {
        return nonExpiredJWT()
    }
}
