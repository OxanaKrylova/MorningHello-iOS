//
//  OrthodoxHolidayProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 31/07/2026.
//

import Foundation

struct OrthodoxHolidayProvider {

    // MARK: - Страстная неделя и Пасха

    static func holyWeekContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current
        let year = calendar.component(
            .year,
            from: date
        )

        guard let easterDate =
                orthodoxEasterDate(for: year) else {
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

        switch difference {

        // Понедельник перед Пасхой
        case 6:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Monday"
                ],
                phrases: [
                    "Пусть начало Страстной недели принесёт тишину в сердце, ясность мыслей и душевный покой."
                ],
                category: "Православный"
            )

        // Вторник перед Пасхой
        case 5:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Tuesday"
                ],
                phrases: [
                    "Пусть этот день станет временем добрых мыслей, искренней молитвы и внутреннего света."
                ],
                category: "Православный"
            )

        // Среда перед Пасхой
        case 4:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Wednesday"
                ],
                phrases: [
                    "Желаю душевного спокойствия, терпения и сил пройти эти особенные дни с верой и любовью."
                ],
                category: "Православный"
            )

        // Чистый четверг
        case 3:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Thursday"
                ],
                phrases: [
                    "В Чистый четверг пусть в доме будет мир, в мыслях — чистота, а в сердце — любовь и надежда."
                ],
                category: "Православный"
            )

        // Страстная пятница
        case 2:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Friday"
                ],
                phrases: [
                    "Пусть Страстная пятница наполнит сердце смирением, состраданием и тихой надеждой."
                ],
                category: "Православный"
            )

        // Великая суббота
        case 1:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Saturday"
                ],
                phrases: [
                    "Пусть Великая суббота пройдёт в мире, тишине и ожидании светлой пасхальной радости."
                ],
                category: "Православный"
            )

        // Пасхальное воскресенье
        case 0:
            let easterPhrases = [
                "Христос воскрес! Пусть этот день наполнит ваш дом уютом, а сердце — любовью и покоем.",
                "Христос воскрес! Желаю вашей семье крепкого здоровья, благополучия и чтобы каждый день был согрет Божьим благословением.",
                "Со Светлой Пасхой! Желаю, чтобы в жизни было побольше светлых моментов, гармонии и добра.",
                "Со Светлой Пасхой! Пусть рядом всегда будут люди, с которыми тепло и радостно!",
                "Со светлым праздником Пасхи! Мира, душевного спокойствия, и пусть всё задуманное обязательно сбудется!"
            ]

            let phraseIndex = stableDailyIndex(
                count: easterPhrases.count,
                salt: 1200,
                date: date
            )

            return HolidayContent(
                images: [
                    "holiday_easter"
                ],
                phrases: [
                    easterPhrases[phraseIndex]
                ],
                category: "Православный"
            )

        default:
            return nil
        }
    }

    // MARK: - Прощёное воскресенье

    static func forgivenSundayContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current
        let year = calendar.component(
            .year,
            from: date
        )

        guard let easterDate = orthodoxEasterDate(
            for: year
        ),
        let forgivenSundayDate = calendar.date(
            byAdding: .day,
            value: -56,
            to: easterDate
        ) else {
            return nil
        }

        guard calendar.isDate(
            date,
            inSameDayAs: forgivenSundayDate
        ) else {
            return nil
        }

        return HolidayContent(
            images: [
                "Holiday_ForgivenSunday"
            ],
            phrases: [
                "В Прощёное воскресенье прошу прощения за всё и желаю мира, добра и душевного спокойствия."
            ],
            category: "Православный"
        )
    }

    // MARK: - Фиксированные православные праздники

    static func fixedContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }

        // 7 января — Рождество Христово
        if day == 7 && month == 1 {
            return HolidayContent(
                images: [
                    "holiday_orthodox_christmas"
                ],
                phrases: [
                    "С Рождеством Христовым!",
                    "Пусть свет Рождества наполнит ваш дом любовью, миром и Божией благодатью."
                ],
                category: "Православный"
            )
        }

        // 19 января — Крещение Господне
        if day == 19 && month == 1 {
            return HolidayContent(
                images: [
                    "holiday_epiphany"
                ],
                phrases: [
                    "С Крещением!",
                    "Пусть в душе будет свет и мир!"
                ],
                category: "Православный"
            )
        }

        // 15 февраля — Сретение Господне
        if day == 15 && month == 2 {
            return HolidayContent(
                images: [
                    "holiday_meeting"
                ],
                phrases: [
                    "Со Сретением Господним!"
                ],
                category: "Православный"
            )
        }

        // 7 апреля — Благовещение
        if day == 7 && month == 4 {
            return HolidayContent(
                images: [
                    "holiday_annunciation"
                ],
                phrases: [
                    "С Благовещением!",
                    "Пусть этот день принесёт добрые вести!"
                ],
                category: "Православный"
            )
        }

        // Вербное воскресенье — за 7 дней до Пасхи
        if let easterDate = orthodoxEasterDate(
            for: year
        ),
        let palmSundayDate = calendar.date(
            byAdding: .day,
            value: -7,
            to: easterDate
        ),
        calendar.isDate(
            date,
            inSameDayAs: palmSundayDate
        ) {
            return HolidayContent(
                images: [
                    "holiday_palm_sunday"
                ],
                phrases: [
                    "С Вербным воскресеньем!"
                ],
                category: "Православный"
            )
        }

        // 7 июля — Иван Купала
        if day == 7 && month == 7 {
            return HolidayContent(
                images: [
                    "holiday_kupalo"
                ],
                phrases: [
                    "С праздником Ивана Купалы!",
                    "С Днём Ивана Купалы!"
                ],
                category: "Православный"
            )
        }

        // 8 июля — День семьи, любви и верности
        if day == 8 && month == 7 {
            return HolidayContent(
                images: [
                    "holiday_family_love"
                ],
                phrases: [
                    "С Днём семьи, любви и верности!",
                    "Пусть в доме всегда будут любовь, тепло и согласие!"
                ],
                category: "Православный"
            )
        }

        // 28 июля — День крещения Руси
        if day == 28 && month == 7 {
            return HolidayContent(
                images: [
                    "holiday_baptism"
                ],
                phrases: [
                    "С Днём крещения Руси!"
                ],
                category: "Православный"
            )
        }

        // 19 августа — Яблочный Спас
        if day == 19 && month == 8 {
            return HolidayContent(
                images: [
                    "Holiday_Apple"
                ],
                phrases: [
                    "С Яблочным Спасом! Пусть Господь благословит ваш дом, подарит здоровье, мир и добрые плоды ваших трудов.",
                    "Поздравляю с Яблочным Спасом! Желаю душевного тепла, семейного счастья и Божией благодати.",
                    "Пусть Яблочный Спас наполнит сердце благодарностью, дом — достатком, а каждый день — радостью и светом."
                ],
                category: "Православный"
            )
        }

        // 28 августа — Успение Пресвятой Богородицы
        if day == 28 && month == 8 {
            return HolidayContent(
                images: [
                    "holiday_dormition"
                ],
                phrases: [
                    "С Успением Пресвятой Богородицы!",
                    "Пусть этот день принесёт мир, свет и душевное спокойствие."
                ],
                category: "Православный"
            )
        }

        return nil
    }

    // MARK: - Дата православной Пасхи

    private static func orthodoxEasterDate(
        for year: Int
    ) -> Date? {

        let easterDates: [
            Int: (
                day: Int,
                month: Int
            )
        ] = [
            2026: (12, 4),
            2027: (2, 5),
            2028: (16, 4),
            2029: (8, 4),
            2030: (28, 4)
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
