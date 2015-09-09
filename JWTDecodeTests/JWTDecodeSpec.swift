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

class JWTDecodeSpec: QuickSpec {

    override func spec() {
        describe("decode") {

            it("should tell a jwt is expired") {
                expect(expiredJWT().expired).to(beTruthy())
            }

            it("should tell a jwt is not expired") {
                expect(nonExpiredJWT().expired).to(beFalsy())
            }

            it("should tell a jwt is expired with a close enough timestamp") {
                expect(jwtThatExpiresAt(NSDate()).expired).to(beTruthy())
            }

            it("should obtain payload") {
                let jwt = jwtWithBody(["sub": "myid", "name": "Shawarma Monk"])
                let payload = jwt.body as! [String: String]
                expect(payload).to(equal(["sub": "myid", "name": "Shawarma Monk"]))
            }

            it("should return expire date") {
                expect(expiredJWT().expiresAt).toNot(beNil())
            }

            it("should decode valid jwt") {
                let jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
                expect(try! decode(jwt)).toNot(beNil())
            }

            it("should raise exception with invalid jwt") {
                expect { try decode("HEADER.BODY.SIGNATURE") }.to(throwError())
            }

            it("should raise exception with missing parts") {
                expect { try decode("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ") }.to(throwError())
            }

        }

        describe("jwt parts") {
            let jwt = try! decode("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ.xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7ZXm4QpVvXnY")

            it("should return header") {
                expect(jwt.header as? [String: String]).to(equal(["alg": "HS256", "typ": "JWT"]))
            }

            it("should return body") {
                expect(jwt.body as? [String: String]).to(equal(["sub": "sub"]))
            }

            it("should return signature") {
                expect(jwt.signature).to(equal("xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7ZXm4QpVvXnY"))
            }
        }

        describe("claims") {
            var jwt: JWT!

            describe("expiresAt claim") {

                it("should handle expired jwt") {
                    jwt = expiredJWT()
                    expect(jwt.expiresAt).toNot(beNil())
                    expect(jwt.expired).to(beTruthy())
                }

                it("should handle non-expired jwt") {
                    jwt = nonExpiredJWT()
                    expect(jwt.expiresAt).toNot(beNil())
                    expect(jwt.expired).to(beFalsy())
                }

                it("should handle jwt without expiresAt claim") {
                    jwt = jwtWithBody(["sub": NSUUID().UUIDString])
                    expect(jwt.expiresAt).to(beNil())
                    expect(jwt.expired).to(beFalsy())
                }
            }

            describe("custom claim") {

                beforeEach {
                    jwt = jwtWithBody(["sub": NSUUID().UUIDString, "custom_claim": "Shawarma Friday!", "custom_integer_claim": 10])
                }

                it("should return custom claims") {
                    let stringValue: String? = jwt.claim("custom_claim")
                    expect(stringValue).to(equal("Shawarma Friday!"))
                    let integerValue: Int? = jwt.claim("custom_integer_claim")
                    expect(integerValue).to(equal(10))
                }

                it("should return nil when claim is not present") {
                    let unknownClaim: String? = jwt.claim("missing_claim")
                    expect(unknownClaim).to(beNil())
                }
            }
        }

        describe("JWTDecoder") {

            let decoder = nonExpiredJWT()

            it("should check is not expired") {
                expect(decoder.expired).to(beFalsy())
            }

            it("should return the payload") {
                expect(decoder.body).toNot(raiseException())
            }

            it("should return exp date") {
                expect(decoder.expiresAt).toNot(beNil())
            }
        }
    }
}
