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

func jwt(withBody body: [String: Any]) -> JWT {
    var jwt: String = ""
    do {
        let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        let base64 = data.base64EncodedString(options: NSData.Base64EncodingOptions())
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(base64).SIGNATURE"
    } catch _ {
        NSException(name: NSExceptionName.invalidArgumentException, reason: "Failed to build jwt", userInfo: nil).raise()
    }
    return try! decode(jwt: jwt)
}

func jwtThatExpiresAt(date: Date) -> JWT {
    return jwt(withBody: ["exp": date.timeIntervalSince1970 as AnyObject])
}

func expiredJWT() -> JWT {
    let seconds = Int(arc4random_uniform(60) + 1) * -1
    let date = (Calendar.current as NSCalendar).date(byAdding: .second, value: seconds, to: Date(), options: NSCalendar.Options())
    return jwtThatExpiresAt(date: date!)
}

func nonExpiredJWT() -> JWT {
    let hours = Int(arc4random_uniform(200) + 1)
    let date = (Calendar.current as NSCalendar).date(byAdding: .hour, value: hours, to: Date(), options: NSCalendar.Options())
    return jwtThatExpiresAt(date: date!)
}

class JWTHelper: NSObject {

    class func newJWT(withBody body: [String: AnyObject]) -> JWT {
        return jwt(withBody: body)
    }

    class func newJWTThatExpiresAt(date: Date) -> JWT {
        return jwtThatExpiresAt(date: date)
    }

    class func newExpiredJWT() -> JWT {
        return expiredJWT()
    }

    class func newNonExpiredJWT() -> JWT {
        return nonExpiredJWT()
    }
}
