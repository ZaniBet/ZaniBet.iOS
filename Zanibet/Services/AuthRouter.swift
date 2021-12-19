//
//  AuthRouter.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 25/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

enum AuthRouter: URLRequestConvertible {
    
    static let baseURLString = HTTPHelper.SERVER_URL
    case postSignup([String: Any])
    case postSignin([String: Any])
    case postSigninWithFacebook([String: Any])
    case putResetPassword([String: Any])
    
    func asURLRequest() throws -> URLRequest {
        // Configurer la method HTTP pour chaque route
        var method: HTTPMethod {
            switch self {
            case .postSignup, .postSignin, .postSigninWithFacebook:
                return .post
            case .putResetPassword:
                return .put
            }
        }
        
        // Configurer les parametres pour chaques routes
        var params: ([String: Any]?) = {
            switch self {
            case .postSignup(let user):
                return (user)
            case .postSignin(let user):
                return (user)
            case .postSigninWithFacebook(let facebookToken):
                return (facebookToken)
            case .putResetPassword(let email):
                return (email)
            }
        }()
        
        // Configuer l'url de query pour chaque route
        let url: URL = {
            let relativePath: String?
            switch self {
            case .postSignup:
                relativePath = "user"
            case .postSignin:
                relativePath = "oauth/token"
            case .postSigninWithFacebook:
                relativePath = "auth/facebook"
            case .putResetPassword:
                relativePath = "auth/resetPassword"
            }
            
            var url = URL(string: AuthRouter.baseURLString)!
            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            return url
        }()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        params?.updateValue(HTTPHelper.CLIENT_ID, forKey: "client_id")
        params?.updateValue(HTTPHelper.CLIENT_SECRET, forKey: "client_secret")
        params?.updateValue("password", forKey: "grant_type")
        
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
