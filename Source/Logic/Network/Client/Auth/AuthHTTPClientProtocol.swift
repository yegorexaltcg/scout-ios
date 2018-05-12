//
//  AuthHTTPClientProtocol.swift
//  Scout
//
//  Created by Victor Liubchenko on 5/12/18.
//

import Foundation

typealias CreateNewUserSuccessBlock = (_ userToken: String) -> ()
typealias CreateNewUserFailureBlock = HTTPClientFailureBlock

protocol AuthHTTPClientProtocol {
    
    @discardableResult
    func createUser(withUserName userName: String,
                                    email: String,
                                 password: String,
                             successBlock: @escaping CreateNewUserSuccessBlock,
                             failureBlock: @escaping CreateNewUserFailureBlock) -> HTTPClientConnectionResult
}
