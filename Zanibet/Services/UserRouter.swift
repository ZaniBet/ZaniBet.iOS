//
//  UserRouter.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 26/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

enum UserRouter: URLRequestConvertible {
    
    static let baseURLString = HTTPHelper.SERVER_URL + "v4/"
    case putUser([String: Any])
    case putUserEmail([String: Any])
    case putUserApnToken([String: Any])
    case getUser()
    case putExtra([String: Any])
    case putFcmToken([String: Any])
    case putJeton()
    case putInvitationCode(String)

    func asURLRequest() throws -> URLRequest {
        // Configurer la method HTTP pour chaque route
        var method: HTTPMethod {
            switch self {
            case .putUser, .putUserEmail, .putUserApnToken, .putExtra, .putFcmToken, .putJeton, .putInvitationCode:
                return .put
            case .getUser:
                return .get
            }
        }
        
        // Configurer les parametres pour chaques routes
        let params: ([String: Any]?) = {
            switch self {
            case .putUser(let user):
                return (user)
            case .putUserEmail(let email):
                return (email)
            case .putUserApnToken(let apnToken):
                return (apnToken)
            case .putExtra(let extra):
                return (extra)
            case .putFcmToken(let fcmToken):
                return (fcmToken)
            case .putJeton():
                return nil
            case .putInvitationCode:
                return nil
            case .getUser:
                return nil
            }
        }()
        
        // Configuer l'url de query pour chaque route
        let url: URL = {
            let relativePath: String?
            switch self {
            case .putUser:
                relativePath = "user"
            case .putUserEmail:
                relativePath = "user/email"
            case .putUserApnToken:
                relativePath = "user/apntoken"
            case .putExtra:
                relativePath = "user/extra"
            case .putFcmToken:
                relativePath = "user/fcmtoken"
            case .putJeton:
                relativePath = "user/jeton"
            case .putInvitationCode(let code):
                relativePath = "user/invitation/\(code)"
            case .getUser:
                relativePath = "user"
            }
            
            var url = URL(string: UserRouter.baseURLString)!
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
