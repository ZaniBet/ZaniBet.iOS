//
//  GrilleRouter.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 26/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

enum GrilleRouter: URLRequestConvertible {
    
    static let baseURLString = HTTPHelper.SERVER_URL + "v5/"
    case getGrilles([String: Any])
    case getSinglePlayedGrille(String)
    case postGrille([String: Any])
    case postSingleGrille([String: Any])
    case putCancelGrille(Int)
    
    func asURLRequest() throws -> URLRequest {
        // Configurer la method HTTP pour chaque route
        var method: HTTPMethod {
            switch self {
            case .getGrilles:
                return .get
            case .getSinglePlayedGrille:
                return .get
            case .postGrille:
                return .post
            case .postSingleGrille:
                return .post
            case .putCancelGrille:
                return .put
            }
        }
        
        // Configurer les parametres pour chaques routes
        let params: ([String: Any]?) = {
            switch self {
            case .getGrilles(let status):
                return (status)
            case .getSinglePlayedGrille:
                return nil
            case .postGrille(let grille):
                return (grille)
            case .postSingleGrille(let grille):
                return (grille)
            case .putCancelGrille:
                return nil
            }
        }()
        
        // Configuer l'url de query pour chaque route
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getGrilles:
                relativePath = "grilles"
            case .getSinglePlayedGrille(let ticketId):
                relativePath = "grilles/single/gameticket/\(ticketId)"
            case .postGrille:
                relativePath = "grilles"
            case .postSingleGrille:
                relativePath = "grilles/single"
            case .putCancelGrille(let grilleId):
                relativePath = "grilles/\(grilleId)/cancel"
            }
            
            var url = URL(string: GrilleRouter.baseURLString)!
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
        
        var encoding: ParameterEncoding {
            switch self {
            case .getGrilles:
                return URLEncoding.queryString
            case .getSinglePlayedGrille:
                return JSONEncoding.default
            case .postGrille:
                return JSONEncoding.default
            case .postSingleGrille:
                return JSONEncoding.default
            case .putCancelGrille:
                return JSONEncoding.default
            }
        }
        return try encoding.encode(urlRequest, with: params)
    }
    
}
