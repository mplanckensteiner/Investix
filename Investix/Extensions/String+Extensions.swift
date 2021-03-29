//
//  String+Extensions.swift
//  Investix
//
//  Created by Miguel Planckensteiner on 2/18/21.
//

import Foundation


extension String {
    
    func addBrackets() -> String {
        
        return "(\(self))"
    }
    
    func prefix(withText text: String) -> String {
        
        return text + self
    }
}
