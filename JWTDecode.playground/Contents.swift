/*: 
# JWTDecode.swift
A swift framework to help you decode a [JWT](http://jwt.io) token in your iOS/OSX applications
*/

//: First we need to import JWTDecode framework
import JWTDecode

/*: 
Then paste here the token you wish to decode
*/
let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.LvF9wSheCB5xarpydmurWgi9NOZkdES5AbNb_UWk9Ew"
//: You can generate a new token in [jwt.io](http://jwt.io)

/*: 
## Decode
Then here we try to decode it calling `decode(token: String) -> JWT` that will return an object with all the decoded values
*/
do {
    let jwt = try decode(jwt: token)

//: ### JWT parts

//: Header dictionary
    jwt.header
//: Claims in token body
    jwt.body
//: Token signature
    jwt.signature

//: ### Registered Claims

//: "aud" (Audience)
    jwt.audience
//: "sub" (Subject)
    jwt.subject
//: "jti" (JWT ID)
    jwt.identifier
//: "iss" (Issuer)
    jwt.issuer
//: "nbf" (Not Before)
    jwt.notBefore
//: "iat" (Issued At)
    jwt.issuedAt
//: "exp" (Expiration Time)
    jwt.expiresAt

//: ### Custom Claims
//: If we also have our custom claims we can retrive them calling `claim<T>(name: String) -> T?` where `T` is the value type of the claim, e.g.: a `String`

    let custom = jwt.claim(name: "email").string
//: ### Error Handling
//: If the token is invalid an `NSError` will be thrown
} catch let error as NSError {
    error.localizedDescription
}
