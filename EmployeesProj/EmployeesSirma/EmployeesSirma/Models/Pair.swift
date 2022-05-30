//
//  Pair.swift
//  EmployeesSirma
//
//  Created by Ivan Velkov on 29.5.22.
//

import Foundation

struct Pair {
    let pairId: String
    let employeeIds: [String]
    var experience: [WorkExperience]
    
    var longestExperience: WorkExperience? {
        let sortedExperience = experience.sorted(by: { $0.workDays > $1.workDays })
        let experience = sortedExperience.first
        return experience
    }
}

struct WorkExperience {
    let projectId: String
    let workDays: Int
}
