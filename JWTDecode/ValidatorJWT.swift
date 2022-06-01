import Foundation

protocol ValidatorJWT {
    var issuer: String { get }
    var audience: String { get }

    func validate(_ jwt: JWT, nonce: String?) -> ValidationError?
}
