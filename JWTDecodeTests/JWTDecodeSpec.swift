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
                expect(jwtThatExpiresAt(date: Date()).expired).to(beTruthy())
            }

            it("should obtain payload") {
                let token = jwt(withBody: ["sub": "myid", "name": "Shawarma Monk"])
                let payload = token.body as! [String: String]
                expect(payload).to(equal(["sub": "myid", "name": "Shawarma Monk"]))
            }

            it("should return original jwt string representation") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
                let jwt = try! decode(jwt: jwtString)
                expect(jwt.string).to(equal(jwtString))
            }

            it("should return expire date") {
                expect(expiredJWT().expiresAt).toNot(beNil())
            }

            it("should decode valid jwt") {
                let jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
                expect(try! decode(jwt: jwt)).toNot(beNil())
            }

            it("should raise exception with invalid json in jwt") {
                let token = "HEADER.BODY.SIGNATURE"
                expect { try decode(jwt: token) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beDecodeErrorWithCode(.invalidJSON("HEADER")))
                    })
            }

            it("should raise exception with missing parts") {
                let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ"
                expect { try decode(jwt: token) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beDecodeErrorWithCode(.invalidPartCount(token, 2)))
                    })
            }

        }

        describe("jwt parts") {
            let jwt = try! decode(jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ.xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7ZXm4QpVvXnY")

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
            var token: JWT!

            describe("expiresAt claim") {

                it("should handle expired jwt") {
                    token = expiredJWT()
                    expect(token.expiresAt).toNot(beNil())
                    expect(token.expired).to(beTruthy())
                }

                it("should handle non-expired jwt") {
                    token = nonExpiredJWT()
                    expect(token.expiresAt).toNot(beNil())
                    expect(token.expired).to(beFalsy())
                }

                it("should handle jwt without expiresAt claim") {
                    token = jwt(withBody: ["sub": UUID().uuidString])
                    expect(token.expiresAt).to(beNil())
                    expect(token.expired).to(beFalsy())
                }
            }

            describe("registered claims") {

                let jwt = try! decode(jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.LvF9wSheCB5xarpydmurWgi9NOZkdES5AbNb_UWk9Ew")


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

                    let jwt = try! decode(jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiaHR0cHM6Ly9zYW1wbGVzLmF1dGgwLmNvbSIsImh0dHBzOi8vYXBpLnNhbXBsZXMuYXV0aDAuY29tIl19.cfWFPuJbQ7NToa-BjHgHD1tHn3P2tOP5wTQaZc1qg6M")

                    it("should return all audiences") {
                        expect(jwt.audience).to(equal(["https://samples.auth0.com", "https://api.samples.auth0.com"]))
                    }
                }

                it("should return issued at") {
                    expect(jwt.issuedAt).to(equal(Date(timeIntervalSince1970: 1372638336)))
                }

                it("should return not before") {
                    expect(jwt.notBefore).to(equal(Date(timeIntervalSince1970: 1372638336)))
                }

                it("should return jwt id") {
                    expect(jwt.identifier).to(equal("qwerty123456"))
                }
            }

            describe("custom claim") {

                beforeEach {
                    token = jwt(withBody: ["sub": UUID().uuidString, "custom_claim": "Shawarma Friday!", "custom_integer_claim": 10, "custom_double_claim": 3.4, "custom_double_string_claim": "1.3"])
                }

                it("should return string claim") {
                    let claim = token.claim(name: "custom_claim")
                    expect(claim.string) == "Shawarma Friday!"
                    expect(claim.array) == ["Shawarma Friday!"]
                    expect(claim.integer).to(beNil())
                    expect(claim.date).to(beNil())
                    expect(claim.double).to(beNil())
                }

                it("should return integer claim") {
                    let claim = token.claim(name: "custom_integer_claim")
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 10
                    expect(claim.double) == 10.0
                    expect(claim.date) == Date(timeIntervalSince1970: 10)
                }

                it("should return double claim") {
                    let claim = token.claim(name: "custom_double_claim")
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 3
                    expect(claim.double) == 3.4
                    expect(claim.date) == Date(timeIntervalSince1970: 3.4)
                }

                it("should return double as string claim") {
                    let claim = token.claim(name: "custom_double_string_claim")
                    expect(claim.string) == "1.3"
                    expect(claim.array) == ["1.3"]
                    expect(claim.integer).to(beNil())
                    expect(claim.double) == 1.3
                    expect(claim.date) == Date(timeIntervalSince1970: 1.3)
                }

                it("should return no value when clain is not present") {
                    let unknownClaim = token.claim(name: "missing_claim")
                    expect(unknownClaim.array).to(beNil())
                    expect(unknownClaim.string).to(beNil())
                    expect(unknownClaim.integer).to(beNil())
                    expect(unknownClaim.double).to(beNil())
                    expect(unknownClaim.date).to(beNil())
                }
            }
        }
    }
}

public func beDecodeErrorWithCode(_ code: DecodeError) -> NonNilMatcherFunc<Error> {
    return NonNilMatcherFunc { (actualExpression, failureMessage) throws in
        failureMessage.postfixMessage = "be decode error with code <\(code)>"
        guard let actual = try actualExpression.evaluate() as? DecodeError else {
            return false
        }
        return actual == code
    }
}

extension DecodeError: Equatable {}

public func ==(lhs: DecodeError, rhs: DecodeError) -> Bool {
    return lhs.localizedDescription == rhs.localizedDescription
}
