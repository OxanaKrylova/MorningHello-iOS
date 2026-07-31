//
//  SukkotPostcardProvider..swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/08/2026.
//

import Foundation

struct SukkotPostcardProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        /*
         Еврейский праздничный день начинается в 18:00.

         Поэтому после 18:00 считаем, что уже наступил
         следующий календарный день праздника.
         */
        let effectiveDate: Date

        let hour = calendar.component(
            .hour,
            from: date
        )

        if hour >= 18 {
            guard let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: date
            ) else {
                return nil
            }

            effectiveDate = nextDay
        } else {
            effectiveDate = date
        }

        let year = calendar.component(
            .year,
            from: effectiveDate
        )

        /*
         Первый календарный день Суккота.

         Благодаря effectiveDate открытка первого дня
         начнёт показываться уже в 18:00 накануне.
         */
        let startDates: [Int: DateComponents] = [
            2026: DateComponents(
                year: 2026,
                month: 9,
                day: 26
            ),
            2027: DateComponents(
                year: 2027,
                month: 10,
                day: 16
            ),
            2028: DateComponents(
                year: 2028,
                month: 10,
                day: 5
            )
        ]

        guard let startComponents = startDates[year],
              let startDate = calendar.date(
                from: startComponents
              ) else {
            return nil
        }

        let currentDay = calendar.startOfDay(
            for: effectiveDate
        )

        let firstDay = calendar.startOfDay(
            for: startDate
        )

        guard let dayDifference = calendar.dateComponents(
            [.day],
            from: firstDay,
            to: currentDay
        ).day else {
            return nil
        }

        // Суккот длится 7 дней.
        guard (0...6).contains(dayDifference) else {
            return nil
        }

        let images = [
            "Sukkot_1",
            "Sukkot_2",
            "Sukkot_3",
            "Sukkot_4",
            "Sukkot_5",
            "Sukkot_6",
            "Sukkot_7"
        ]

        let phrases = [
            "С праздником Суккот! Пусть ваш шалаш будет полон радости, уюта и тепла.",
            "Желаю вам и вашей семье крепкого здоровья, мира в доме и изобилия на столе. Хаг самеах!",
            "Счастливого Суккота! Пусть этот светлый праздник принесёт в вашу жизнь гармонию, благополучие и душевный покой.",
            "С праздником Кущей! Пусть временный шалаш напоминает о вечной заботе Свыше.",
            "Поздравляю с Суккотом — временем нашей радости!",
            "С праздником Суккот! Пусть эти праздничные дни наполнят душу чистыми мыслями.",
            "С праздником Суккот! Пусть радость этого дня останется с вами на весь год!"
        ]

        let index = dayDifference

        guard images.indices.contains(index),
              phrases.indices.contains(index) else {
            return nil
        }

        return HolidayContent(
            images: [
                images[index]
            ],
            phrases: [
                phrases[index]
            ],
            category: "Еврейский"
        )
    }
}
