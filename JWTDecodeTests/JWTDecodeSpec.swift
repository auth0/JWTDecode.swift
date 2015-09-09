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

            it("should raise exception with invalid json in jwt") {
                expect { try decode("HEADER.BODY.SIGNATURE") }
                    .to(throwError { (error: ErrorType) in
                        expect(error).to(beDecodeErrorWithCode(.InvalidJSONValue))
                    })
            }

            it("should raise exception with missing parts") {
                expect { try decode("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ") }
                    .to(throwError { (error: ErrorType) in
                        expect(error).to(beDecodeErrorWithCode(.InvalidPartCount))
                    })
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

            describe("registered claims") {

                let jwt = try! decode("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.LvF9wSheCB5xarpydmurWgi9NOZkdES5AbNb_UWk9Ew")


                it("should return issuer") {
                    expect(jwt.issuer).to(equal("https://samples.auth0.com"))
                }

                it("should return subject") {
                    expect(jwt.subject).to(equal("auth0|1010101010"))
                }

                it("should return single audience") {
                    expect(jwt.audience).to(equal(["https://samples.auth0.com"]))
                }

                context("multiple audiences") {

                    let jwt = try! decode("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiaHR0cHM6Ly9zYW1wbGVzLmF1dGgwLmNvbSIsImh0dHBzOi8vYXBpLnNhbXBsZXMuYXV0aDAuY29tIl19.cfWFPuJbQ7NToa-BjHgHD1tHn3P2tOP5wTQaZc1qg6M")

                    it("should return all audiences") {
                        expect(jwt.audience).to(equal(["https://samples.auth0.com", "https://api.samples.auth0.com"]))
                    }
                }

                it("should return issued at") {
                    expect(jwt.issuedAt).to(equal(NSDate(timeIntervalSince1970: 1372638336)))
                }

                it("should return not before") {
                    expect(jwt.notBefore).to(equal(NSDate(timeIntervalSince1970: 1372638336)))
                }

                it("should return jwt id") {
                    expect(jwt.identifier).to(equal("qwerty123456"))
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
    }
}

public func beDecodeErrorWithCode(code: DecodeErrorCode) -> NonNilMatcherFunc<ErrorType> {
    return NonNilMatcherFunc { (actualExpression, failureMessage) throws in
        failureMessage.postfixMessage = "be decode error with code <\(code)>"
        guard let actual = try actualExpression.evaluate() else {
            return false
        }
        return actual._domain == "com.auth0.JWTDecode" && actual._code == code.rawValue
    }
}
