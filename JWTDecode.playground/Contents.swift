/*:
 # JWTDecode.swift
 Easily decode a [JWT](https://jwt.io/) and access the claims it contains.
 */
/*:
 ## Getting Started
 First, import the JWTDecode framework.
 */
import JWTDecode
/*:
 Then, paste here the token you wish to decode.
 */
let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2LCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJjdXN0b20iOlsxLDIsM119.i71AXss9VcKxiuULNMq7LqAXjtjweNlXPVNf529vXdM"
//: You can generate a new token in [jwt.io](http://jwt.io).
/*:
 ## Decode
 Try to decode it by calling `decode(token:)`. That will return an object with all the decoded values.
 */
do {
    let jwt = try decode(jwt: token)

    // JWT parts

    // Header dictionary
    jwt.header

    // Claims in token body
    jwt.body

    // Token signature
    jwt.signature

    // Registered Claims

    // "aud" (Audience)
    jwt.audience

    // "sub" (Subject)
    jwt.subject

    // "jti" (JWT ID)
    jwt.identifier

    // "iss" (Issuer)
    jwt.issuer

    // "nbf" (Not Before)
    jwt.notBefore

    // "iat" (Issued At)
    jwt.issuedAt

    // "exp" (Expiration Time)
    jwt.expiresAt

    // Custom Claims
    // You can retrieve a custom claim through a subscript and then attempt to convert the value to a specific type.
    _ = jwt["email"].string
    _ = jwt["custom"].rawValue as? [Int]

    // Error Handling
    // If the JWT is malformed the `decode(jwt:)` function will throw a `JWTDecodeError`.
} catch let error as JWTDecodeError {
    error
}
