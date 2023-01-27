//
//  UserGithubModel.swift
//  Test ATS
//
//  Created by Bambang on 25/01/23.
//

import SwiftyJSON

struct UserGithubModel {
    var id: Int = 0
    var name: String = ""
    var avatarUrl: String = ""
    var htmlUrl: String = ""
    
    var error_title: String = ""
    var error_message: String = ""
    
    init() {
    }
    
    init(newId: Int, newName: String, newAvatarUrl: String, newHtmlUrl: String) {
        self.id = newId
        self.name = newName
        self.avatarUrl = newAvatarUrl
        self.htmlUrl = newHtmlUrl
    }
    
    init(error_title: String, error_message: String) {
        self.error_title = error_title
        self.error_message = error_message
    }
    
    init(dictionary: JSON) {
        id = dictionary["id"].intValue
        if(dictionary["login"].exists()) {
            name = dictionary["login"].stringValue
        }
        if(dictionary["avatar_url"].exists()) {
            avatarUrl = dictionary["avatar_url"].stringValue
        }
        if(dictionary["html_url"].exists()) {
            htmlUrl = dictionary["html_url"].stringValue
        }
    }
    
    func isError() -> Bool {
        return !self.error_title.isEmpty || !self.error_message.isEmpty
    }
    
}
