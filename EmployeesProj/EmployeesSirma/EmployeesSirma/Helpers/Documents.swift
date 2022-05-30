//
//  Documents.swift
//  EmployeesSirma
//
//  Created by Ivan Velkov on 29.5.22.
//

import Foundation

class Documents {
  
    static let sharedInstance = Documents()
    
    private func importData(name: String, type: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: name, ofType: type) else {
            return nil
        }
        do {
            let file = try String(contentsOfFile: filePath, encoding: .utf8)
            return file
        } catch {
            print("Couldnt read file \(name)")
            return nil
        }
    }
    
    private func parseRawData(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            let formattedColumns = columns.map { string in
                return string.replacingOccurrences(of: " ", with: "")
            }
            result.append(formattedColumns)
        }
        
        return result
    }
    
    func readDataFromFile(file: Files) -> [[String]]? {
        guard let file = importData(name: file.rawValue, type: file.fileType) else {
            return nil
        }
        let parsedData = parseRawData(data: file)
        return parsedData
    }
    
    enum Files:String {
        case employees = "employees"
        
        var fileType: String {
            switch self {
            case .employees:
                return "csv"
            }
        }
                
        var dateFormat: String {
            switch self {
            case .employees:
                return "yyyy-MM-dd"
            }
        }
    }
}

