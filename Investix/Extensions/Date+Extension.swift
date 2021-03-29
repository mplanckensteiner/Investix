//
//  Date+Extension.swift
//  Investix
//
//  Created by Miguel Planckensteiner on 2/18/21.
//

import Foundation


extension Date {
    
    var MMYYFormat: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return dateFormatter.string(from: self)
    }
    
}
