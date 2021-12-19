//
//  PayoutRouter.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 26/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

enum PayoutRouter: URLRequestConvertible {
    
    static let baseURLString = HTTPHelper.SERVER_URL
    case getPayouts()
    case postPayoutReward([String: Any])
    
    func asURLRequest() throws -> URLRequest {
        // Configurer la method HTTP pour chaque route
        var method: HTTPMethod {
            switch self {
            case .getPayouts:
                return .get
            case .postPayoutReward:
                return .post
            }
        }
        
        // Configurer les parametres pour chaques routes
        let params: ([String: Any]?) = {
            switch self {
            case .getPayouts:
                return nil
            case .postPayoutReward(let payout):
                return (payout)
            }
        }()
        
        // Configuer l'url de query pour chaque route
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getPayouts:
                relativePath = "payouts"
            case .postPayoutReward:
                relativePath = "payout/reward"
            }
            
            var url = URL(string: AuthRouter.baseURLString)!
            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            return url
        }()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let keychain = KeychainSwift()
        let accessToken = keychain.get("access_token")
        urlRequest.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        if let langStr = Locale.current.languageCode {
            urlRequest.setValue(langStr, forHTTPHeaderField: "Accept-Language")
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            urlRequest.setValue(version, forHTTPHeaderField: "iOS-App-Code")
        }
        
        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
    
}
