@testable import Authentication
import Foundation
import XCTest

final class DateCalculationTests: XCTestCase {
    func testCalculateAge() {
        // skip test on january 1st
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: date)
        if components.month == 1 && components.day == 1 {
            return
        }

        let testCases = [
            ("1950-01-02T00:00:00+10:00", Calendar.current.component(.year, from: Date()) - 1950),
            ("1980-01-01T00:00:00Z", Calendar.current.component(.year, from: Date()) - 1980),
            ("2000-01-01T00:00:00Z", Calendar.current.component(.year, from: Date()) - 2000),
            ("2005-01-01T00:00:00.000Z", Calendar.current.component(.year, from: Date()) - 2005),
            ("2010-01-01T00:00:00-10:00", Calendar.current.component(.year, from: Date()) - 2010),
        ]

        for (birthdate, expectedAge) in testCases {
            if let age = calculateAge(from: birthdate) {
                XCTAssertEqual(age, expectedAge, "Age calculation is incorrect for birthdate \(birthdate). Expected \(expectedAge), got \(age).")
            } else {
                XCTFail("Valid date string \(birthdate) should return an age")
            }
        }

        // Test case with an invalid date
        XCTAssertNil(calculateAge(from: "invalid-date-string"), "Invalid date string should return nil")
    }
}
