//
//  Item.swift
//  WishList
//
//  Created by 钱正轩 on 2020/11/3.
//

import UIKit
import os.log

class Item: NSObject {
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var wish: String?
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items.data")
    
    //MARK: Types
    
    struct PropertyKey{
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
        static let wish = "wish"
    }
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int, wish: String?) {
        guard !name.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.rating = rating
        self.wish = wish
    }
    
    required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Item object", log: .default, type: .debug)
            return nil
        }
        let photo = coder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let rating = coder.decodeInteger(forKey: PropertyKey.rating)
        let wish = coder.decodeObject(forKey: PropertyKey.wish) as? String
        self.init(name: name, photo: photo, rating:rating, wish:wish)
    }
}

extension Item: NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(photo, forKey: PropertyKey.photo)
        coder.encode(rating, forKey: PropertyKey.rating)
        coder.encode(wish, forKey: PropertyKey.wish)
    }
}
