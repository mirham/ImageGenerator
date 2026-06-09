//
//  StringExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.06.2026.
//


extension String {
    func filteringNumericInput(allowDecimal: Bool = true) -> String {
        var result = self.filter {
            $0.isNumber
            || (allowDecimal
                && ($0 == Constants.dotChar || $0 == Constants.commaChar ))
        }
        
        if allowDecimal {
            var foundSeparator = false
            
            result = result.filter { char in
                if char == Constants.dotChar  || char == Constants.commaChar {
                    if foundSeparator
                    { return false }
            
                    foundSeparator = true
                }
                
                return true
            }
        }
        
        return result
    }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
}
