//
//  URLRequest+Extension.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

// MARK: - URLRequest Debugging Helper
extension URLRequest {
    var curlString: String {
        var components = ["curl -v"]
        
        if let method = httpMethod {
            components.append("-X \(method)")
        }
        
        for (key, value) in allHTTPHeaderFields ?? [:] {
            components.append("-H '\(key): \(value)'")
        }
        
        if let body = httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            components.append("-d '\(bodyString)'")
        }
        
        components.append("'\(url?.absoluteString ?? "")'")
        
        let curlCommand = components.joined(separator: " \\\n\t")
        
        let separator = "\n---------- cURL Request ----------\n"
        
        return "\(separator)\(curlCommand)\n---------------------------------\n"
    }
}


