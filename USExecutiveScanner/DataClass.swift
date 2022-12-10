//
//  DataClass.swift
//  USExecutiveScanner
//
//  Created by Mortuza Hossain on 10/12/22.
//

import Foundation

struct CheckResponse: Codable {
    let msg, code: String
    let data: DataClass
}

struct DataClass: Codable {
    let id, name, zipcode, sorttype: String
    let pd, bay, status, createdat: String
    let updatedat: String
}
