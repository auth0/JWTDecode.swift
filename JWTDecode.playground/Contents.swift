//: Playground - noun: a place where people can play

import JWTDecode

let id_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImV4cCI6MTQ0MTM5NjgwMH0.fJHsc1QnBioH9mCJwA5yltDrxlYaIAadgmVWXPy7FXk"


do {
    let jwt = try decode(id_token)
    jwt.expiresAt
    jwt.payload
    jwt.signature
    if let admin: Bool = jwt.claim("admin") {
        admin
    }
} catch let error as NSError {
    error.localizedDescription
}

let decoded = try A0JWT.decode(id_token)