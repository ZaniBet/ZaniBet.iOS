//
//  TransactionRouter.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 21/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

enum TransactionRouter: URLRequestConvertible {
    
    static let baseURLString = HTTPHelper.SERVER_URL
    case getReferralTransactions()
    
    func asURLRequest() throws -> URLRequest {
        // Configurer la method HTTP pour chaque route
        var method: HTTPMethod {
            switch self {
            case .getReferralTransactions:
                return .get
            }
        }
        
        // Configurer les parametres pour chaques routes
        let params: ([String: Any]?) = {
            switch self {
            case .getReferralTransactions:
                return nil
            }
        }()
        
        // Configuer l'url de query pour chaque route
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getReferralTransactions:
                relativePath = "transactions/referral"
            }
            
            var url = URL(string: TransactionRouter.baseURLString)!
            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            return url
        }()
        
        // Construire la requête
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // Inclure le token dans le header
        let keychain = KeychainSwift()
        let accessToken = keychain.get("access_token")
        urlRequest.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        // Ajouter si possible la langue du client
        if let langStr = Locale.current.languageCode {
            urlRequest.setValue(langStr, forHTTPHeaderField: "Accept-Language")
        }
        
        // Indiquer la version de l'application
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            urlRequest.setValue(version, forHTTPHeaderField: "iOS-App-Code")
        }
        
        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
    
}


