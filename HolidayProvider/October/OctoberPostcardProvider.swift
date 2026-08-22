//
//  OctoberPostcardProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 19/08/2026.
//

import Foundation

struct OctoberPostcardProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let month = calendar.component(
            .month,
            from: date
        )

        guard month == 10 else {
            return nil
        }

        let images = (1...20).map {
            "October_\($0)"
        }

        let phrases = [
            "Пусть октябрьское утро подарит спокойствие, тепло и ощущение щедрости осени.",
            "Желаю тёплого дня, добрых мыслей и маленьких радостей, которыми так богата осень.",
            "Пусть сегодняшний день будет ярким, уютным и наполненным приятными событиями.",
            "Желаю золотого настроения, душевного тепла и хороших новостей.",
            "Пусть осень щедро подарит вам спокойствие, вдохновение и поводы для улыбки.",
            "Желаю уютного октября, тёплых встреч и ощущения благодарности за всё хорошее.",
            "Пусть сегодняшний день принесёт богатый урожай добрых мыслей и счастливых мгновений.",
            "Желаю ясного утра, спокойного сердца и прекрасного осеннего настроения.",
            "Пусть октябрь наполнит дом уютом, а день — теплом и добрыми событиями.",
            "Желаю, чтобы сегодня было больше ярких красок, приятных встреч и душевного спокойствия.",
            "Пусть этот осенний день будет щедрым на хорошие новости и тёплые улыбки.",
            "Желаю начать день с благодарности, спокойствия и ожидания чего-то хорошего.",
            "Пусть октябрьское утро принесёт вдохновение, уют и желание наслаждаться каждым мгновением.",
            "Желаю тёплого дома, добрых людей рядом и красивого осеннего дня.",
            "Пусть сегодня всё складывается легко, спокойно и по-осеннему уютно.",
            "Желаю богатого урожая хороших событий, приятных мыслей и счастливых минут.",
            "Пусть золотая осень подарит вам тепло, гармонию и светлое настроение.",
            "Желаю неспешного утра, хорошего настроения и времени для того, что действительно радует.",
            "Пусть этот октябрьский день будет ярким, добрым и наполненным уютом.",
            "Желаю вам тепла в сердце, достатка в доме и много красивых мгновений этой осени."
        ]

        let availableCount = min(
            images.count,
            phrases.count
        )

        guard availableCount > 0 else {
            return nil
        }

        let index = stableDailyIndex(
            count: availableCount,
            salt: 1000,
            date: date
        )

        return HolidayContent(
            images: [
                images[index]
            ],
            phrases: [
                phrases[index]
            ],
            category: "Октябрь"
        )
    }


    // MARK: - Стабильный индекс дня

    private static func stableDailyIndex(
        count: Int,
        salt: Int = 0,
        date: Date = Date()
    ) -> Int {

        guard count > 0 else {
            return 0
        }

        let components =
            Calendar.current.dateComponents(
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
