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

final class AgeGroupTests: XCTestCase {
    /// `start` used to be hardcoded to 65 for every band, so a 42-year-old reported
    /// ageGroup "37 - 50" alongside ageGroupStart 65.
    func testStartMatchesTheRange() {
        let cases: [(age: Int, range: String, start: Int)] = [
            (0, "< 10", 0),
            (9, "< 10", 0),
            (10, "10 - 12", 10),
            (12, "10 - 12", 10),
            (13, "13 - 18", 13),
            (18, "13 - 18", 13),
            (19, "19 - 25", 19),
            (25, "19 - 25", 19),
            (26, "26 - 36", 26),
            (36, "26 - 36", 26),
            (37, "37 - 50", 37),
            (42, "37 - 50", 37),
            (50, "37 - 50", 37),
            (51, "51 - 64", 51),
            (64, "51 - 64", 51),
            (65, "65+", 65),
            (99, "65+", 65),
        ]

        for expected in cases {
            let result = getAgeGroup(expected.age)
            XCTAssertEqual(result.range, expected.range, "wrong range for age \(expected.age)")
            XCTAssertEqual(result.start, expected.start, "wrong start for age \(expected.age)")
        }
    }

    func testUnknownAge() {
        let result = getAgeGroup(nil)
        XCTAssertEqual(result.range, "UNKNOWN")
        XCTAssertEqual(result.start, 999)
    }
}
