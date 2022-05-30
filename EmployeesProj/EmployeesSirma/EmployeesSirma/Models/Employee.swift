//
//  Employee.swift
//  EmployeesSirma
//
//  Created by Ivan Velkov on 29.5.22.
//

import Foundation

struct Employee {
    let id: String
    let projectId: String
    let dateFrom: Date
    let dateTo: Date
    
    enum elementOrder: Int {
        case id
        case projectId
        case dateFrom
        case dateTo
    }
}
