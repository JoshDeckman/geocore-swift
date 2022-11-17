//
//  GeocoreGroupTag.swift
//  GeocoreKit


import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

open class GeocoreGroupTagQuery: GeocoreRelationshipQuery {
    open func with(group: GeocoreGroup) -> Self {
        guard let groupId = group.id else {
            return self
        }
        return self.with(object1Id: groupId)
    }
    
    open func with(tag: GeocoreTag) -> Self {
        guard let tagId = tag.id else {
            return self
        }
        return self.with(object2Id: tagId)
    }
    
    open func all() -> Promise<[GeocoreGroupTag]> {
        if self.id1 != nil {
            return Geocore.sharedInstance.promisedGET(super.buildPath(forService: "/groups", withSubPath: "/tags"))
        }
        return Promise { resolver in resolver.reject(GeocoreError.invalidParameter(message: "Expecting id")) }
    }
}

open class GeocoreGroupTag: GeocoreRelationship {
    
    fileprivate(set) open var group: GeocoreGroup?
    fileprivate(set) open var tag: GeocoreTag?
    
    public override init() {
        super.init()
    }
    
    public required init(_ json: JSON) {
        if let pk = json["pk"].dictionary {
            if let group = pk["group"] {
                self.group = GeocoreGroup.init(group)
            }
            if let tag = pk["tag"] {
                self.tag = GeocoreTag.init(tag)
            }
        }
        super.init(json)
    }
}
