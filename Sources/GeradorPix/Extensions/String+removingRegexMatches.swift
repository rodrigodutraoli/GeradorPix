//
//  String+removingRegexMatches.swift
//  
//
//  Created by Rodrigo Dutra de Oliveira on 7/7/22.
//

import Foundation

extension String {
    func removingRegexMatches(pattern: String, replaceWith: String = "") -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        let res = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        
        return res
    }
}
