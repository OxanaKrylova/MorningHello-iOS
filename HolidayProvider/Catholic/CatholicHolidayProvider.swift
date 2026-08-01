//
//  CatholicHolidayProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/08/2026.
//

import Foundation

struct CatholicHolidayProvider {

    // MARK: - Фиксированные и заранее заданные праздники

    static func fixedContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [
                .year,
                .month,
                .day,
                .weekday,
                .weekOfMonth
            ],
            from: date
        )

        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let weekday = components.weekday,
              let weekOfMonth = components.weekOfMonth else {
            return nil
        }

        // 6 января — Богоявление
        if day == 6 && month == 1 {
            return HolidayContent(
                images: [
                    "holiday_epithany"
                ],
                phrases: [
                    "С праздником Богоявления!"
                ],
                category: "Католический"
            )
        }

        // 17 марта — День святого Патрика
        if day == 17 && month == 3 {
            return HolidayContent(
                images: [
                    "holiday_Patrick"
                ],
                phrases: [
                    "С Днём святого Патрика!",
                    "Пусть удача, радость и добро будут рядом!"
                ],
                category: "Католический"
            )
        }

        // Вознесение Господне
        if
            (year == 2026 && month == 5 && day == 14) ||
            (year == 2027 && month == 5 && day == 6) ||
            (year == 2028 && month == 5 && day == 25) {

            return HolidayContent(
                images: [
                    "holiday_Ascension"
                ],
                phrases: [
                    "С Вознесением Господним!"
                ],
                category: "Католический"
            )
        }

        // Праздник Святой Троицы
        if
            (year == 2026 && month == 5 && day == 24) ||
            (year == 2027 && month == 5 && day == 16) ||
            (year == 2028 && month == 6 && day == 4) {

            return HolidayContent(
                images: [
                    "holiday_trinity"
                ],
                phrases: [
                    "С праздником Святой Троицы!"
                ],
                category: "Католический"
            )
        }

        // 24 июня — Рождество святого Иоанна Крестителя
        if day == 24 && month == 6 {
            return HolidayContent(
                images: [
                    "Holiday_LaSaint_Jean"
                ],
                phrases: [
                    "С днём святого Иоанна Крестителя! Пусть вера, надежда и внутренний свет всегда помогают идти правильной дорогой."
                ],
                category: "Католический"
            )
        }

        // 6 августа — Преображение Господне
        if day == 6 && month == 8 {
            return HolidayContent(
                images: [
                    "Holiday_Tranfiguration"
                ],
                phrases: [
                    "С праздником Преображения Господня! Пусть свет Христов озаряет ваш путь, наполняя сердце миром, надеждой и любовью.",
                    "В день Преображения Господня желаю духовной радости, крепкой веры и Божьего благословения.",
                    "Пусть праздник Преображения напоминает о силе света, добра и любви, преображающих нашу жизнь."
                ],
                category: "Католический"
            )
        }

        // 31 октября — Хеллоуин
        if day == 31 && month == 10 {
            return HolidayContent(
                images: [
                    "holiday_halloween"
                ],
                phrases: [
                    "С Хеллоуином!",
                    "Пусть этот вечер будет добрым и волшебным!"
                ],
                category: "Католический"
            )
        }

        // 1 ноября — День всех святых
        if day == 1 && month == 11 {
            return HolidayContent(
                images: [
                    "holiday_AllSaints"
                ],
                phrases: [
                    "С Днём всех святых!"
                ],
                category: "Католический"
            )
        }

        /*
         День благодарения:
         четвёртый четверг ноября.

         В Calendar.current:
         5 — четверг.
         */
        if month == 11 &&
            weekday == 5 &&
            weekOfMonth == 4 {

            return HolidayContent(
                images: [
                    "holiday_thanksgiving"
                ],
                phrases: [
                    "С Днём Благодарения!",
                    "Пусть ваш дом будет наполнен семейным счастьем и благодарностью за каждый новый день."
                ],
                category: "Католический"
            )
        }

        // 8 декабря — Непорочное зачатие
        if day == 8 && month == 12 {
            return HolidayContent(
                images: [
                    "holiday_Conception"
                ],
                phrases: [
                    "С праздником Непорочного зачатия Пресвятой Богородицы!"
                ],
                category: "Католический"
            )
        }

        // 24 и 25 декабря — Рождество
        if
            (day == 24 && month == 12) ||
            (day == 25 && month == 12) {

            return HolidayContent(
                images: [
                    "holiday_christmas",
                    "holiday_christmas_2",
                    "holiday_christmas_3"
                ],
                phrases: [
                    "С Рождеством!",
                    "Пусть Рождество принесёт тепло и свет!"
                ],
                category: "Католический"
            )
        }

        return nil
    }

    // MARK: - Католическая Страстная неделя и Пасха

    static func holyWeekContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let year = calendar.component(
            .year,
            from: date
        )

        guard let easterDate =
                catholicEasterDate(for: year) else {
            return nil
        }

        let currentDay = calendar.startOfDay(
            for: date
        )

        let easterDay = calendar.startOfDay(
            for: easterDate
        )

        guard let difference = calendar.dateComponents(
            [.day],
            from: currentDay,
            to: easterDay
        ).day else {
            return nil
        }

        let commonPhrases = [
            "Пусть эти святые дни принесут душевный покой, надежду и внутренний свет.",
            "Желаю мира в сердце, добрых мыслей и тихой радости в ожидании Пасхи.",
            "Пусть вера, любовь и надежда поддерживают вас и ваших близких.",
            "Пусть этот день наполнится молитвой, спокойствием и добрыми поступками.",
            "Желаю душевного равновесия, мира в доме и Божьего благословения."
        ]

        let phraseIndex = stableDailyIndex(
            count: commonPhrases.count,
            salt: 1300,
            date: date
        )

        let phrase = commonPhrases[phraseIndex]

        switch difference {

        case 6:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Monday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )

        case 5:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Tuesday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )

        case 4:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Wednesday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )

        case 3:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Thursday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )

        case 2:
            return HolidayContent(
                images: [
                    "Catholic_Good_Friday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )

        case 1:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Saturday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )

        case 0:
            let easterPhrases = [
                "Христос воскрес! Пусть Пасха наполнит ваш дом светом, любовью и надеждой.",
                "Со Светлой Пасхой! Желаю мира, здоровья и благополучия вашей семье.",
                "С Пасхой Христовой! Пусть радость Воскресения согревает сердца ваших близких."
            ]

            let easterPhraseIndex = stableDailyIndex(
                count: easterPhrases.count,
                salt: 1310,
                date: date
            )

            return HolidayContent(
                images: [
                    "holiday_catholic_passover"
                ],
                phrases: [
                    easterPhrases[easterPhraseIndex]
                ],
                category: "Католический"
            )

        default:
            return nil
        }
    }

    // MARK: - Pancake Day

    static func pancakeDayContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let year = calendar.component(
            .year,
            from: date
        )

        guard let easterDate = catholicEasterDate(
            for: year
        ),
        let pancakeDayDate = calendar.date(
            byAdding: .day,
            value: -47,
            to: easterDate
        ) else {
            return nil
        }

        guard calendar.isDate(
            date,
            inSameDayAs: pancakeDayDate
        ) else {
            return nil
        }

        return HolidayContent(
            images: [
                "Holiday_PancakeDay"
            ],
            phrases: [
                "С Блинным днём! Пусть этот день будет тёплым, вкусным и наполненным радостью.",
                "С Pancake Day! Желаю уютного дня, добрых встреч и самых вкусных блинов.",
                "Пусть Блинный день подарит хорошее настроение, домашнее тепло и приятные моменты.",
                "С Блинным днём! Пусть в доме пахнет блинами, а рядом будут любимые люди."
            ],
            category: "Католический"
        )
    }

    // MARK: - Дата католической Пасхи

    private static func catholicEasterDate(
        for year: Int
    ) -> Date? {

        let easterDates: [Int: (day: Int, month: Int)] = [
            2026: (5, 4),
            2027: (28, 3),
            2028: (16, 4)
        ]

        guard let easter = easterDates[year] else {
            return nil
        }

        var components = DateComponents()
        components.year = year
        components.month = easter.month
        components.day = easter.day
        components.hour = 12

        return Calendar.current.date(
            from: components
        )
    }

    // MARK: - Стабильный индекс фразы

    private static func stableDailyIndex(
        count: Int,
        salt: Int = 0,
        date: Date = Date()
    ) -> Int {

        guard count > 0 else {
            return 0
        }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )

        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0

        let dailyNumber =
            year * 10_000 +
            month * 100 +
            day +
            salt

        return abs(dailyNumber) % count
    }
}
