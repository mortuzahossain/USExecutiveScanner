//
//  SessionDefault.swift
//  USExecutiveScanner
//
//  Created by Mortuza Hossain on 10/12/22.
//

import Foundation

struct SessionDefault{
    private static let userDefault = UserDefaults.standard
    static let (sorttype) = ("sorttype")
    
    static func setSortType(_ sortType : String) {
        userDefault.set(sortType , forKey: sorttype)
    }
    
    static func getSortType( ) -> String{
       return userDefault.value(forKey:  sorttype) as? String ?? "1"
    }
}
