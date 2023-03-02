//
//  GeocoreTrackPoint.swift
//  GeocoreKit


import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

open class GeocoreTrackPoint: GeocoreTaggable {
    
    fileprivate(set) open var objectId: String?
    fileprivate(set) open var memo: String?
    fileprivate(set) open var latitude: Double?
    fileprivate(set) open var longitude: Double?
    fileprivate(set) open var accuracy: Double?
    
    public override init() {
        super.init()
    }
    
    public required init(_ json: JSON) {
        if let objectId = json["id"].string {
            self.objectId = objectId
        }
        if let latitude = json["latitude"].double {
            self.latitude = latitude
        }
        if let longitude = json["longitude"].double {
            self.longitude = longitude
        }
        if let accuracy = json["accuracy"].double {
            self.accuracy = accuracy
        }
        super.init(json)
    }
    
    open override func asDictionary() -> [String: Any] {
        var dict = super.asDictionary()
        if let objectId = self.objectId { dict["id"] = objectId }
        if let memo = self.memo { dict["memo"] = memo }
        if let latitude = self.latitude { dict["latitude"] = latitude }
        if let longitude = self.longitude { dict["longitude"] = longitude }
        if let accuracy = self.accuracy { dict["accuracy"] = accuracy }
        return dict
    }
}
