//
//  ViewController.swift
//  EmployeesSirma
//
//  Created by Ivan Velkov on 29.5.22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var pairs: [Pair] = [] {
        didSet {
            tableView.reloadData()
            printPairsInConsole()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseAppearance()
        loadComponents()
    }

    //MARK: - Base helper functions -

    func baseAppearance() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PairTableViewCell", bundle: nil), forCellReuseIdentifier: PairTableViewCell.cellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension

    }
    
    func loadComponents() {
        guard let rawData = getRawEmployees() else {
            return
        }
        
        let employees = parseRawEmployees(data: rawData)
        let pairs = getPairs(employees: employees)
        self.pairs = pairs
    }
    
    func printPairsInConsole() {
        for pair in pairs {
            guard let experience = pair.longestExperience else {
                return
            }
            var name = ""
            for employee in pair.employeeIds {
                name.append("\(employee), ")
            }
            let text = "\(name)\(experience.projectId), \(experience.workDays)"
            print(text)
        }
    }
    
    //MARK: - Employee helper functions -

    func getRawEmployees() -> [[String]]? {
        guard let rawData = Documents.sharedInstance.readDataFromFile(file: .employees) else {
            return nil
        }
        return rawData
    }
    
    func parseRawEmployees(data: [[String]]) -> [Employee] {
        var employees: [Employee] = []
        for row in data {
            guard row.count == 4 else { continue }
            let id = row[Employee.elementOrder.id.rawValue] as String
            let projectId = row[Employee.elementOrder.projectId.rawValue] as String
            let dateFrom = row[Employee.elementOrder.dateFrom.rawValue] as String
            let dateTo = row[Employee.elementOrder.dateTo.rawValue] as String
            let format = Documents.Files.employees.dateFormat
            
            guard let formattedDateFrom = dateFrom.formattedFromDate(format: format), let formattedDateTo = dateTo.formattedDateTo(format: format) else {
                continue
            }
            
            let employee = Employee(id: id, projectId: projectId, dateFrom: formattedDateFrom, dateTo: formattedDateTo)
            employees.append(employee)
        }
        return employees
    }
    
    func mapEmployeesByProject(employees: [Employee]) -> [String:[Employee]] {
        let projectIds = Array(Set(employees.map { $0.projectId }))
        var mappedEmployees: [String: [Employee]] = [:]
        for id  in projectIds {
            let filteredEmployees = employees.filter{ return $0.projectId == id }
            mappedEmployees[id] = filteredEmployees
        }
        return mappedEmployees
    }
    
    func filterEmployees(employee: Employee, employees: [Employee]) -> [Employee] {
        let newEmployees = employees.filter{ return $0.id != employee.id }
        return newEmployees
    }
    
    func generateEmployeeIdArray(firstEmployee: Employee, secondEmployee: Employee) -> [String] {
        let array = [firstEmployee.id, secondEmployee.id].sorted()
        return array
    }

    //MARK: - Pair helper functions -

    func getPairs(employees: [Employee]) -> [Pair] {
        let employeesDict = mapEmployeesByProject(employees: employees)
        let pairs = generatePairs(employeesDict: employeesDict)
        return pairs
    }
    
    func generatePairs(employeesDict: [String:[Employee]]) -> [Pair] {
        var pairs: [Pair] = []
        for (projectId, employees) in employeesDict {
            for firstEmployee in employees {
                let otherEmployees = filterEmployees(employee: firstEmployee, employees: employees)
                for secondEmployee in otherEmployees {
                    
                    let pairId = generatePairId(firstEmployee: firstEmployee, secondEmployee: secondEmployee)

                    let daysTogether = daysOfWorkingTogether(firstEmployee: firstEmployee, secondEmployee: secondEmployee)
                    
                    if var existingPair = getPairById(pairId: pairId, pairs: pairs) {
                        if pairHasExperience(pair: existingPair, projectId: projectId) {
                            // pair exists AND they have experience on this project
                            continue
                        }
                        if daysTogether > 0 {
                            // pair exists but they have no experience on this project
                            let experience = WorkExperience(projectId: projectId, workDays: daysTogether)
                            existingPair.experience.append(experience)
                        }

                    } else if daysTogether > 0 {
                        // pair doesnt exist and they have experience together
                        let employeeIds = generateEmployeeIdArray(firstEmployee: firstEmployee, secondEmployee: secondEmployee)
                        let experience = WorkExperience(projectId: projectId, workDays: daysTogether)
                        let newPair = Pair(pairId: pairId, employeeIds: employeeIds, experience: [experience])
                        pairs.append(newPair)
                    }
                }
            }
        }
        return pairs
    }
    

    func getPairById(pairId: String, pairs: [Pair]) -> Pair? {
        let pair = pairs.filter {$0.pairId == pairId }.first
        return pair
    }
    
    func daysOfWorkingTogether(firstEmployee: Employee, secondEmployee: Employee) -> Int {
        if doesDateFitBetweenRange(date: secondEmployee.dateFrom, startDate: firstEmployee.dateFrom, endDate: firstEmployee.dateTo) {
            
            let firstDate = secondEmployee.dateFrom
            let secondDate = firstEmployee.dateTo < secondEmployee.dateTo ? firstEmployee.dateTo : secondEmployee.dateTo
            
            let days = Calendar.current.numberOfDaysBetween(firstDate, and: secondDate)
            return days
            
        } else if doesDateFitBetweenRange(date: firstEmployee.dateFrom, startDate: secondEmployee.dateFrom, endDate: secondEmployee.dateTo){
            let firstDate = firstEmployee.dateFrom
            let secondDate = secondEmployee.dateTo < firstEmployee.dateTo ? secondEmployee.dateTo : firstEmployee.dateTo
            let days = Calendar.current.numberOfDaysBetween(firstDate, and: secondDate)
            return days
        }
        return 0
    }
    
    func doesDateFitBetweenRange(date: Date, startDate: Date, endDate: Date) -> Bool {
        let bool = (startDate...endDate).contains(date)
        return bool
    }
    
    func pairHasExperience(pair: Pair, projectId: String) -> Bool {
        let bool = pair.experience.contains { experience in
            return experience.projectId == projectId
        }
        return bool
    }
    
    func generatePairId(firstEmployee: Employee, secondEmployee: Employee) -> String {
        
        let array = generateEmployeeIdArray(firstEmployee: firstEmployee, secondEmployee: secondEmployee)
        var id = ""
        for element in array {
            id.append(element)
        }
        return id
    }
}

extension ViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pairs.count
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PairTableViewCell.cellIdentifier, for: indexPath) as! PairTableViewCell
        let pair = pairs[indexPath.row]
        cell.pair = pair
        return cell
    }
}

