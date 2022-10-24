//
//  GeocoreGroup.swift
//  GeocoreKit


import Foundation

open class GeocoreGroupQuery: GeocoreTaggableQuery {
    
    fileprivate(set) open var parentId: String?
    
    open func with(parentId: String) -> Self {
        self.parentId = parentId
        return self
    }
    
    open override func buildQueryParameters() -> Alamofire.Parameters {
        var dict = super.buildQueryParameters()
        if let parentId = self.parentId {
            dict["parent"] = parentId
        }
        return dict
    }
    
    open func all() -> Promise<[GeocoreGroup]> {
        guard let _ = self.parentId else {
            return Promise { fulfill, reject in reject(GeocoreError.invalidParameter(message: "Expecting parent id")) }
        }
        return self.all(forService: "/groups")
    }
}

open class GeocoreGroup: GeocoreTaggable {
    
    fileprivate(set) open var enabled: Bool?
    
    public override init() {
        super.init()
    }
    
    public required init(_ json: JSON) {
        if let enabled = json["enabled"] as? Bool {
            self.enabled = enabled
        }
        super.init(json)
    }
    
    open override func asDictionary() -> [String: Any] {
        var dict = super.asDictionary()
        if let enabled = self.enabled { dict["enabled"] = enabled }
        return dict
    }
}
