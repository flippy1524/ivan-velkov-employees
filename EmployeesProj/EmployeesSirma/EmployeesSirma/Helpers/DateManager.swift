//
//  DateManager.swift
//  EmployeesSirma
//
//  Created by Ivan Velkov on 30.5.22.
//

import Foundation

class DateManager {
  static let shared = DateManager()
  private init() {}
  
  private let defaultDateFormat = "EEEE dd MMMM yyyy"
  
  private lazy var dateFormatter: DateFormatter = {
    let _dateFormatter = DateFormatter()
    _dateFormatter.locale = Bundle.main.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
    
    return _dateFormatter
  }()
  
 
  func date(from string: String, format: String? = nil) -> Date? {
    guard let dateFormat = format ?? dateFormat(for: string) else { return nil }
    
    dateFormatter.dateFormat = dateFormat
    return dateFormatter.date(from: string)
  }
  
  private func dateFormat(for string: String) -> String? {
    let dateFormats = [
      (dateFormat: "yyyy-MM-dd",
       regex: "^(19|20)\\d\\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$"),
      (dateFormat: "yyyy-MM-dd HH:mm:ss",
       regex: "^(19|20)\\d\\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])$")
    ]
    
    return dateFormats
      .filter { string.range(of: $0.regex, options: .regularExpression) != nil }
      .first
      .map { $0.dateFormat }
  }
}

