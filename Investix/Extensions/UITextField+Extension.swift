//
//  UITextField+Extension.swift
//  Investix
//
//  Created by Miguel Planckensteiner on 2/18/21.
//

import UIKit


extension UITextField {
    
    func addDoneButton() {
        
        let screenWidth = UIScreen.main.bounds.width
        let doneToolBar: UIToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        doneToolBar.barStyle = .default
        let flexBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dissmissKeyboard))
        
        let items = [flexBarButtonItem, doneBarButtonItem]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        inputAccessoryView = doneToolBar
    
    }
    
    @objc private func dissmissKeyboard() {
        resignFirstResponder()
    }
}
