//
//  ValidationError.swift
//  JWTDecode
//
//  Created by Martin Walsh on 10/12/2018.
//  Copyright © 2018 Auth0. All rights reserved.
//

import Foundation

public enum ValidationError: Error {
    case invalidClaim(String)
    case expired
    case nonce
}
