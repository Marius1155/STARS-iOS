//
//  DateExtensions.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 02.12.2025.
//

import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
