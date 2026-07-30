//
//  HanukkahPostcardProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/07/2026.
//
import Foundation

struct HanukkahPostcardProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        var gregorianCalendar = Calendar(
            identifier: .gregorian
        )
        gregorianCalendar.timeZone = .current

        var hebrewCalendar = Calendar(
            identifier: .hebrew
        )
        hebrewCalendar.timeZone = .current

        /*
         Сдвигаем время на 6 часов вперёд.

         Благодаря этому:
         17:59 остаётся предыдущим еврейским днём,
         а 18:00 уже считается следующим днём.
         */
        guard let shiftedDate = gregorianCalendar.date(
            byAdding: .hour,
            value: 6,
            to: date
        ) else {
            return nil
        }

        let hebrewComponents = hebrewCalendar.dateComponents(
            [.year],
            from: shiftedDate
        )

        guard let hebrewYear = hebrewComponents.year else {
            return nil
        }

        /*
         В календаре Foundation:

         месяц 3 — Кислев;
         Ханука начинается 25 Кислева.
         */
        var hanukkahStartComponents = DateComponents()
        hanukkahStartComponents.calendar = hebrewCalendar
        hanukkahStartComponents.timeZone = .current
        hanukkahStartComponents.year = hebrewYear
        hanukkahStartComponents.month = 3
        hanukkahStartComponents.day = 25

        guard let hanukkahStartDate = hebrewCalendar.date(
            from: hanukkahStartComponents
        ) else {
            return nil
        }

        let currentDay = gregorianCalendar.startOfDay(
            for: shiftedDate
        )

        let firstHanukkahDay = gregorianCalendar.startOfDay(
            for: hanukkahStartDate
        )

        let dayDifference = gregorianCalendar.dateComponents(
            [.day],
            from: firstHanukkahDay,
            to: currentDay
        ).day ?? -1

        /*
         Ханука длится восемь дней.

         Индексы:
         0 — первая открытка;
         1 — вторая;
         ...
         7 — восьмая.
         */
        guard (0..<8).contains(dayDifference) else {
            return nil
        }

        let images = [
            "hanuka_lights_1",
            "hanuka_lights_2",
            "hanuka_lights_3",
            "hanuka_lights_4",
            "hanuka_lights_5",
            "hanuka_lights_6",
            "hanuka_lights_7",
            "hanuka_lights_8"
        ]

        let phrases = [
            "Пусть первый огонёк Хануки принесёт в дом свет, надежду и душевное тепло.",
            "Пусть второй ханукальный огонёк наполнит сердце радостью, а дом — уютом.",
            "Пусть свет третьей свечи подарит спокойствие, добрые встречи и счастливые мгновения.",
            "Пусть четвёртый огонёк Хануки напомнит, что свет всегда побеждает темноту.",
            "Пусть пятая свеча озарит дом любовью, согласием и семейным теплом.",
            "Пусть шестой ханукальный огонёк принесёт здоровье, благополучие и хорошие новости.",
            "Пусть свет седьмой свечи укрепит веру в чудеса и исполнение добрых желаний.",
            "Пусть все огни Хануки сияют ярко и наполняют жизнь миром, радостью и счастьем."
        ]

        return HolidayContent(
            images: [
                images[dayDifference]
            ],
            phrases: [
                phrases[dayDifference]
            ],
            category: "hanukkah"
        )
    }
}
