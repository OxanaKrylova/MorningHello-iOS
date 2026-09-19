//
//  ProtestantHolidayProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 18/09/2026.
//

import Foundation

struct ProtestantHolidayProvider {

    private struct Occasion {
        let date: Date?
        let asset: String
        let russian: String
        let english: String
    }

    static let assetNames: [String] = [
        "Protestant_AllSaints'Day",
        "Protestant_AscensionDay",
        "Protestant_AshWednesday",
        "Protestant_Christmas",
        "Protestant_EasterSunday",
        "Protestant_Epiphany",
        "Protestant_Father'sDay",
        "Protestant_GoodFriday",
        "Protestant_MaundyThursday",
        "Protestant_Mother'sDay",
        "Protestant_NationalDayPrayer",
        "Protestant_PalmSunday",
        "Protestant_Pentecost",
        "Protestant_ReformationDay",
        "Protestant_ReformationSunday",
        "Protestant_ReligiousFreedomDay",
        "Protestant_Thanksgiving",
        "Protestant_Transfiguration"
    ]

    static func content(for date: Date = Date()) -> HolidayContent? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let year = calendar.component(.year, from: date)
        guard let easter = easterDate(year: year, calendar: calendar),
              let ashWednesday = offset(-46, from: easter, calendar: calendar),
              let goodFriday = offset(-2, from: easter, calendar: calendar),
              let palmSunday = offset(-7, from: easter, calendar: calendar),
              let maundyThursday = offset(-3, from: easter, calendar: calendar),
              let ascension = offset(39, from: easter, calendar: calendar),
              let pentecost = offset(49, from: easter, calendar: calendar),
              let transfiguration = offset(
                -3,
                from: ashWednesday,
                calendar: calendar
              )
        else {
            return nil
        }

        // Calendar: воскресенье = 1, четверг = 5.
        let occasions: [Occasion] = [
            Occasion(
                date: day(25, 12, year, calendar),
                asset: "Protestant_Christmas",
                russian: "С Рождеством Христовым! Пусть в вашем доме будут мир, надежда и радость.",
                english: "Merry Christmas! May your home be filled with peace, hope, and joy."
            ),
            Occasion(
                date: day(6, 1, year, calendar),
                asset: "Protestant_Epiphany",
                russian: "С Богоявлением! Пусть свет Христов указывает вам путь.",
                english: "Blessed Epiphany! May the light of Christ guide your way."
            ),
            Occasion(
                date: day(16, 1, year, calendar),
                asset: "Protestant_ReligiousFreedomDay",
                russian: "С Днём свободы вероисповедания! Пусть каждый может свободно следовать своей вере.",
                english: "On Religious Freedom Day, may everyone be free to follow their faith."
            ),
            Occasion(
                date: goodFriday,
                asset: "Protestant_GoodFriday",
                russian: "В Страстную пятницу желаю вам времени для молитвы, размышления и надежды.",
                english: "On Good Friday, may you find time for prayer, reflection, and hope."
            ),
            Occasion(
                date: easter,
                asset: "Protestant_EasterSunday",
                russian: "Христос воскрес! Светлой Пасхи, радости и новой надежды!",
                english: "Christ is risen! Wishing you a joyful Easter and renewed hope."
            ),
            Occasion(
                date: ascension,
                asset: "Protestant_AscensionDay",
                russian: "С Вознесением Господним! Пусть вера и надежда укрепляют вас.",
                english: "Blessed Ascension Day! May faith and hope strengthen you."
            ),
            Occasion(
                date: pentecost,
                asset: "Protestant_Pentecost",
                russian: "С Пятидесятницей! Пусть Святой Дух принесёт мир, мудрость и вдохновение.",
                english: "Blessed Pentecost! May the Holy Spirit bring peace, wisdom, and inspiration."
            ),
            Occasion(
                date: ashWednesday,
                asset: "Protestant_AshWednesday",
                russian: "В Пепельную среду желаю вам спокойного времени для молитвы и обновления.",
                english: "On Ash Wednesday, may this season bring prayer, reflection, and renewal."
            ),
            Occasion(
                date: palmSunday,
                asset: "Protestant_PalmSunday",
                russian: "С Пальмовым воскресеньем! Пусть этот день принесёт мир вашему сердцу.",
                english: "Blessed Palm Sunday! May this day bring peace to your heart."
            ),
            Occasion(
                date: maundyThursday,
                asset: "Protestant_MaundyThursday",
                russian: "В Великий четверг желаю вам любви, смирения и доброты к ближним.",
                english: "On Maundy Thursday, may love, humility, and kindness guide you."
            ),
            Occasion(
                date: transfiguration,
                asset: "Protestant_Transfiguration",
                russian: "С Преображенским воскресеньем! Пусть свет Христов дарит вам надежду.",
                english: "Blessed Transfiguration Sunday! May the light of Christ give you hope."
            ),
            Occasion(
                date: nthWeekday(
                    5, occurrence: 4, month: 11,
                    year: year, calendar: calendar
                ),
                asset: "Protestant_Thanksgiving",
                russian: "С Днём благодарения! Пусть рядом будут дорогие люди и поводы для благодарности.",
                english: "Happy Thanksgiving! May you share this day with loved ones and grateful hearts."
            ),
            Occasion(
                date: lastSundayOfOctober(year: year, calendar: calendar),
                asset: "Protestant_ReformationSunday",
                russian: "С Воскресеньем Реформации! Пусть вера помогает вам каждый день.",
                english: "Blessed Reformation Sunday! May faith guide you each day."
            ),
            Occasion(
                date: nthWeekday(
                    1, occurrence: 2, month: 5,
                    year: year, calendar: calendar
                ),
                asset: "Protestant_Mother'sDay",
                russian: "С Днём матери! Спасибо за вашу любовь, заботу и поддержку.",
                english: "Happy Mother's Day! Thank you for your love, care, and support."
            ),
            Occasion(
                date: nthWeekday(
                    1, occurrence: 3, month: 6,
                    year: year, calendar: calendar
                ),
                asset: "Protestant_Father'sDay",
                russian: "С Днём отца! Спасибо за вашу любовь, заботу и поддержку.",
                english: "Happy Father's Day! Thank you for your love, care, and support."
            ),
            Occasion(
                date: nthWeekday(
                    5, occurrence: 1, month: 5,
                    year: year, calendar: calendar
                ),
                asset: "Protestant_NationalDayPrayer",
                russian: "В Национальный день молитвы желаю вам мира, надежды и единения.",
                english: "On the National Day of Prayer, may you find peace, hope, and unity."
            ),
            Occasion(
                date: day(31, 10, year, calendar),
                asset: "Protestant_ReformationDay",
                russian: "С Днём Реформации! Пусть вера вдохновляет вас на добрые дела.",
                english: "Happy Reformation Day! May faith inspire you to do good."
            ),
            Occasion(
                date: day(1, 11, year, calendar),
                asset: "Protestant_AllSaints'Day",
                russian: "В День всех святых с благодарностью вспомним тех, кто был до нас.",
                english: "On All Saints' Day, may we remember with gratitude those who came before us."
            )
        ]

        // Если два праздника совпали, доступны обе открытки
        // с соответствующими им фразами.
        let today = occasions.filter {
            guard let holidayDate = $0.date else { return false }
            return calendar.isDate(holidayDate, inSameDayAs: date)
        }

        guard !today.isEmpty else { return nil }

        let isEnglish = AppLanguage.selected == .englishUS

        return HolidayContent(
            images: today.map(\.asset),
            phrases: today.map { isEnglish ? $0.english : $0.russian },
            category: "Протестантский"
        )
    }

    private static func day(
        _ day: Int,
        _ month: Int,
        _ year: Int,
        _ calendar: Calendar
    ) -> Date? {
        calendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: 12
            )
        )
    }

    private static func offset(
        _ days: Int,
        from date: Date,
        calendar: Calendar
    ) -> Date? {
        calendar.date(byAdding: .day, value: days, to: date)
    }

    private static func nthWeekday(
        _ weekday: Int,
        occurrence: Int,
        month: Int,
        year: Int,
        calendar: Calendar
    ) -> Date? {
        guard let first = day(1, month, year, calendar) else {
            return nil
        }

        let firstWeekday = calendar.component(.weekday, from: first)
        let shift = (weekday - firstWeekday + 7) % 7

        return offset(
            shift + 7 * (occurrence - 1),
            from: first,
            calendar: calendar
        )
    }

    private static func lastSundayOfOctober(
        year: Int,
        calendar: Calendar
    ) -> Date? {
        guard let october31 = day(31, 10, year, calendar) else {
            return nil
        }

        let weekday = calendar.component(.weekday, from: october31)
        return offset(-(weekday - 1), from: october31, calendar: calendar)
    }

    // Западная Пасха по григорианскому календарю.
    private static func easterDate(
        year: Int,
        calendar: Calendar
    ) -> Date? {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k + 70) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let value = h + l - 7 * m + 114

        return day(value % 31 + 1, value / 31, year, calendar)
    }
}
