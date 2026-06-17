//
//  StringExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.06.2026.
//


extension String {
    func filteringNumericInput(allowDecimal: Bool = true) -> String {
        let numericCharacters = self.filter { $0.isNumber }
        
        guard allowDecimal else {
            return numericCharacters
        }
        
        let decimalCharacters = self.filter { $0.isNumber || $0.isDecimalSeparator }
        
        return decimalCharacters.withFirstDecimalSeparatorOnly
    }
    
    var withFirstDecimalSeparatorOnly: String {
        var keepSeparator = true
        
        return self.filter { char in
            if !char.isDecimalSeparator
            { return true }
            
            defer { keepSeparator = false }
            
            return keepSeparator
        }
    }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
}
