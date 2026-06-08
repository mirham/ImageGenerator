//
//  StringExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.06.2026.
//


extension String {
    func filteringNumericInput(allowDecimal: Bool = true) -> String {
        var result = self.filter {
            $0.isNumber || (allowDecimal && ($0 == "." || $0 == ","))
        }
        
        if allowDecimal {
            var foundSeparator = false
            
            result = result.filter { char in
                if char == "." || char == "," {
                    if foundSeparator { return false }
            
                    foundSeparator = true
                }
                return true
            }
        }
        
        return result
    }
}
