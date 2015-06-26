// JWTDecodeSpec.swift
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

import Quick
import Nimble
import JWTDecode

let twoHoursAgo = NSDate(timeIntervalSinceNow: -2 * 60 * 60)
let inTwoHours = NSDate(timeIntervalSinceNow: 2 * 60 * 60)

func jwtWithPayload(payload: [String: AnyObject]) -> String {
    var jwt: String = ""
    if let data = NSJSONSerialization.dataWithJSONObject(payload, options: .allZeros, error: nil) {
        let base64 = data.base64EncodedStringWithOptions(.allZeros)
            .stringByReplacingOccurrencesOfString("+", withString: "-")
            .stringByReplacingOccurrencesOfString("/", withString: "_")
            .stringByReplacingOccurrencesOfString("=", withString: "")
        jwt = "HEADER.\(base64).SIGNATURE"
    } else {
        NSException(name: NSInvalidArgumentException, reason: "Failed to build jwt", userInfo: nil).raise()
    }
    return jwt
}

func jwtThatExpiresAt(date: NSDate) -> String {
    return jwtWithPayload(["exp": date.timeIntervalSince1970])
}

class JWTDecodeSpec: QuickSpec {

    override func spec() {
        describe("Module functions") {

            let nonExpiredJWT = jwtThatExpiresAt(inTwoHours)
            let expiredJWT = jwtThatExpiresAt(twoHoursAgo)

            it("should tell a jwt is expired") {
                expect(JWTDecode.expired(jwt: expiredJWT)).to(beTruthy())
            }

            it("should tell a jwt is not expired") {
                expect(JWTDecode.expired(jwt: nonExpiredJWT)).to(beFalsy())
            }

            it("should obtain payload") {
                let jwt = jwtWithPayload(["sub": "myid", "name": "Shawarma Monk"])
                let payload = JWTDecode.payload(jwt: jwt) as! [String: String]
                expect(payload).to(equal(["sub": "myid", "name": "Shawarma Monk"]))
            }

            it("should return expire date") {
                expect(JWTDecode.expiredDate(jwt: expiredJWT)).toNot(beNil())
            }

            it("should return nil payload for invalid jwt") {
                expect(JWTDecode.payload(jwt: "INVALID")).to(beNil())
            }
        }

        describe("JWTDecoder") {

            let decoder = JWTDecoder(jwt: jwtThatExpiresAt(inTwoHours))

            it("should check is not expired") {
                expect(decoder.expired).to(beFalsy())
            }

            it("should return the payload") {
                expect(decoder.payloadWithError(nil)).toNot(beNil())
            }

            it("should return exp date") {
                expect(decoder.expiredDate).toNot(beNil())
            }

            context("invalid JWT") {
                let decoder = JWTDecoder(jwt: "INVALID")

                it("should return an error for invalid jwt") {
                    var error: NSError?
                    expect(decoder.payloadWithError(&error)).to(beNil())
                    expect(error).toNot(beNil())
                }

                it("should return is expired") {
                    expect(decoder.expired).to(beTruthy())
                }

                it("should return exp date") {
                    expect(decoder.expiredDate).to(beNil())
                }
            }
        }
    }
}
