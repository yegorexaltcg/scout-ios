//
//  ScoutVoiceInputHTTPClientProtocol.swift
//  Scout
//
//  Created by Shurupov Alex on 5/20/18.
//

import Foundation

typealias ScoutVoiceInputSuccessBlock = (_ scoutArticle: ScoutArticle) -> ()
typealias ScoutVoiceInputFailureBlock = HTTPClientFailureBlock

protocol ScoutVoiceInputHTTPClientProtocol {
    func getAudioFileURL(withCmd cmd: String,
                         userid: String,
                         searchTerms: String,
                         successBlock: @escaping ScoutVoiceInputSuccessBlock,
                         failureBlock: @escaping ScoutVoiceInputFailureBlock) -> HTTPClientConnectionResult
}