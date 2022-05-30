//
//  PairTableViewCell.swift
//  EmployeesSirma
//
//  Created by Ivan Velkov on 30.5.22.
//

import UIKit

class PairTableViewCell: UITableViewCell {
    static let cellIdentifier = "PairTableViewCell"

    @IBOutlet var titleLabel: UILabel!
    
    var pair: Pair? {
        didSet {
           setupCell()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func setupCell() {
        guard let pair = pair, let experience = pair.longestExperience else { return }
        
        var name = ""
        for employee in pair.employeeIds {
            name.append("\(employee), ")
        }
        let text = "\(name)\(experience.projectId), \(experience.workDays)"
        titleLabel.text = text
    }
    
}
