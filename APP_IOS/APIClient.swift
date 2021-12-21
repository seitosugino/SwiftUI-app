//
//  APIClient.swift
//  APP_IOS
//
//  Created by 杉野　星都 on 2021/12/22.
//

import Alamofire
import ObjectMapper

enum Result<T> {
    case Success(T)
    case Error(NSError)
}

class APIClient<T> {
}

enum Router: URLRequestConvertible {
    static let baseURLString = "https://itunes.apple.com"

    case API_SEARCH([String: AnyObject])

    var URLRequest: NSMutableURLRequest {

        let (method, path, parameters) : (String, String, [String: AnyObject]) = {

            switch self {
            case .API_SEARCH(let params):
                return ("GET", "/search", params)
            }
        }()

        let URL = NSURL(string: Router.baseURLString)
        let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        URLRequest.HTTPMethod = method
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: parameters).0
    }
}
