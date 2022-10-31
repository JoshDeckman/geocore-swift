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

open class GeocoreUserGroupOperation: GeocoreTaggableOperation {
    fileprivate var group: GeocoreGroup?
    fileprivate var userIdsToAdd: [String] = []
    fileprivate var userIdsToDelete: [String] = []
    fileprivate var customMessage: String? = nil
    
    open func with(group: GeocoreGroup) -> Self {
        self.group = group
        guard let id = group.id else {
            return self
        }
        return self.with(id: id)
    }
    
    open func with(customMessge: String) -> Self {
        self.customMessage = customMessge
        return self
    }
    
    open func add(userId: String) -> Self {
        self.userIdsToAdd.append(userId)
        return self
    }
    
    open func add(userIds: [String]) -> Self {
        userIds.forEach { userId in
            self.userIdsToAdd.append(userId)
        }
        return self
    }
    
    open func delete(userId: String) -> Self {
        userIdsToDelete.append(userId)
        return self
    }
    
    open func delete(userIds: [String]) -> Self {
        userIds.forEach { userId in
            self.userIdsToDelete.append(userId)
        }
        return self
    }
    
    open override func buildQueryParameters() -> Alamofire.Parameters {
        var dict = super.buildQueryParameters()
        if let customMessage = self.customMessage {
            dict["cust_msg"] = customMessage
        }
        if self.userIdsToAdd.count > 0 {
            dict["user_ids"] = self.userIdsToAdd.joined(separator: ",")
        }
        if self.userIdsToDelete.count > 0 {
            dict["del_user_ids"] = self.userIdsToDelete.joined(separator: ",")
        }
        return dict
    }
    
    open func manage() -> Promise<[GeocoreUserGroup]> {
        let params = buildQueryParameters()
        guard let group = self.group else {
            return Promise { resolver in resolver.reject(GeocoreError.invalidParameter(message: "Expecting group")) }
        }
        if params.count > 0 {
            return Geocore.sharedInstance.promisedPOST(
                super.buildPath(forService: "/groups", withSubPath: "/users") ?? "",
                parameters: params,
                body: group.asDictionary())
        } else {
            return Geocore.sharedInstance.promisedPOST(
                super.buildPath(forService: "/groups", withSubPath: "/users") ?? "",
                parameters: group.asDictionary())
        }
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
