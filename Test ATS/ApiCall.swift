//
//  ApiCall.swift
//  Test ATS
//
//  Created by Bambang on 25/01/23.
//

import Alamofire
import SwiftyJSON

struct ApiCall {
    
    static func getHeader() -> HTTPHeaders { // to do : set header if you have a valid authentication key
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else { return [:]}
        guard let token: String = infoDictionary["MyGithubToken"] as? String else { return [:]}
        let headers: HTTPHeaders = [:
//            "Accept":"application/vnd.github+json",
//            "Authorization": "Bearer \(token)"
        ]
        return headers
    }
    
    static func getUsers(query: String, page: Int, completion: @escaping ([UserGithubModel]?, Int) -> Void, onerror: @escaping (String?) -> Void) {
        var results: [UserGithubModel] = []
        let parameters: Parameters = [
            "q": query,
            "page": page,
            "sort": "followers",
            "order": "desc",
            "per_page": 20,
        ]
        print("getUsers API called")
        
        Alamofire.request("https://api.github.com/search/users",
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding(destination: .queryString), headers: getHeader())
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        // No data returned
                        print("empty result")
                        onerror("Empty Result")
                        return
                    }
                    
                    let json = JSON(data)
                    let total_count = json["total_count"].intValue
//                    let incomplete_results = json["incomplete_results"].boolValue
                    let lists = json["items"]
                    
                    for (_, subJson) in lists {
                        let item: UserGithubModel = UserGithubModel(dictionary: subJson)
                        print(subJson)
                        results.append(item)
                    }
                    completion(results, total_count)
                case .failure(let error):
                    switch response.response?.statusCode {
                    case .some(422):
                        onerror("Validation failed, or the endpoint has been spammed")
                    case .some(304):
                        onerror("Not modified")
                    case .some(503):
                        onerror("Service unavailable")
                    case .some(401):
                        onerror("API Validation failed")
                    case .some(403):
                        guard let data = response.data else {
                            return
                        }
                        let json = JSON(data)
                        if json["message"].exists() {
                            onerror(json["message"].stringValue)
                        } else {
                            onerror("response 403 Forbidden")
                        }
                    default:
                        onerror(error.localizedDescription)
                    }
                    
                    print("Error: \(response.response?.statusCode)" ?? "-")
                    print(error)
                }
        }
    }
    
}

