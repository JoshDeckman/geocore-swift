//
//  GeocoreUserGroup.swift
//  GeocoreKit


import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

public enum GeocoreUserGroupType: String {
    case creator = "CREATOR"
    case owner = "OWNER"
    case moderator = "MODERATOR"
    case member = "MEMBER"
}

public enum GeocoreUserGroupApprovalStatus: String {
    case unknown = "UNKNOWN"
    case pending = "PENDING"
    case approved = "APPROVED"
    case regected = "REJECTED"
}

open class GeocoreUserGroupQuery: GeocoreTaggableQuery {
    
    fileprivate(set) open var user: GeocoreUser?
    fileprivate(set) open var group: GeocoreGroup?
    
    open func with(user: GeocoreUser) -> Self {
        self.user = user
        return self.with(id: user.id ?? "")
    }
    
    open func with(group: GeocoreGroup) -> Self {
        self.group = group
        return self.with(id: group.id ?? "")
    }
    
    open func all() -> Promise<[GeocoreUserGroup]> {
        if self.user != nil {
            return Geocore.sharedInstance.promisedGET(super.buildPath(forService: "/users", withSubPath: "/groups") ?? "")
        } else if self.group != nil {
            return Geocore.sharedInstance.promisedGET(super.buildPath(forService: "/groups", withSubPath: "/users") ?? "")
        }
        return Promise { resolver in resolver.reject(GeocoreError.invalidParameter(message: "Expecting id")) }
    }
}

open class GeocoreUserGroup: GeocoreTaggable {
    
    fileprivate(set) open var user: GeocoreUser?
    fileprivate(set) open var group: GeocoreGroup?
    fileprivate(set) open var type: GeocoreUserGroupType?
    fileprivate(set) open var approvalStatus: GeocoreUserGroupApprovalStatus?
    
    public override init() {
        super.init()
    }
    
    public required init(_ json: JSON) {
        if let pk = json["pk"].dictionary {
            if let user = pk["user"] {
                self.user = GeocoreUser.init(user)
            }
            if let group = pk["group"] {
                self.group = GeocoreGroup.init(group)
            }
        }
        if let type = json["type"].string {
            self.type = GeocoreUserGroupType(rawValue: "\(type)")
        }
        if let approvalStatus = json["approvalStatus"].string {
            self.approvalStatus = GeocoreUserGroupApprovalStatus(rawValue: "\(approvalStatus)")
        }
        super.init(json)
    }
}
