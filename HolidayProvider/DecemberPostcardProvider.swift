//
//  DecemberPostcardProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/07/2026.
//

import Foundation

struct DecemberPostcardProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              month == 12 else {
            return nil
        }

        // На 1 декабря уже есть отдельная праздничная открытка.
        guard day != 1 else {
            return nil
        }

        let images = (1...26).map {
            "December_\($0)"
        }

        let phrases = [
            "Пусть декабрьское утро принесёт тепло, уют и добрые новости.",
            "Желаю светлого дня, спокойных мыслей и приятных зимних мгновений.",
            "Пусть этот декабрьский день будет наполнен заботой, радостью и душевным теплом.",
            "Пусть за окном будет прохладно, а в сердце всегда остаётся тепло.",
            "Желаю уютного утра, хорошего настроения и исполнения маленьких желаний.",
            "Пусть сегодняшний день подарит повод улыбнуться и поверить в хорошее.",
            "Желаю тёплых встреч, добрых слов и приятных зимних чудес.",
            "Пусть декабрь наполнит дом светом, сердце — покоем, а день — радостью.",
            "Желаю спокойного утра и прекрасного продолжения дня.",
            "Пусть зимняя атмосфера подарит вдохновение, уют и душевное равновесие.",
            "Желаю, чтобы сегодня вас окружали только добрые люди и хорошие события.",
            "Пусть этот день будет мягким, светлым и наполненным приятными мгновениями.",
            "Желаю зимнего уюта, душевного тепла и прекрасного настроения.",
            "Пусть сегодняшнее утро станет началом доброго и счастливого дня.",
            "Желаю спокойствия в душе, тепла в доме и радости в сердце.",
            "Пусть декабрьский день принесёт хорошие новости и приятные сюрпризы.",
            "Желаю светлых мыслей, тёплых встреч и ощущения приближающегося чуда.",
            "Пусть сегодняшний день подарит вам уют, заботу и искренние улыбки.",
            "Желаю доброго утра и дня, наполненного теплом и благодарностью.",
            "Пусть в этот зимний день найдётся время для отдыха, радости и любимых людей.",
            "Желаю, чтобы холод оставался только за окном, а дома было тепло и спокойно.",
            "Пусть декабрьское утро подарит надежду, вдохновение и хорошее настроение.",
            "Желаю приятного дня, добрых разговоров и счастливых мгновений.",
            "Пусть этот зимний день будет красивым, уютным и по-настоящему добрым.",
            "Желаю тепла в сердце, мира в душе и света в каждом мгновении.",
            "Пусть сегодняшний день станет ещё одной доброй страницей вашей зимы."
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
            salt: year + 1200,
            date: date
        )

        return HolidayContent(
            images: [
                images[index]
            ],
            phrases: [
                phrases[index]
            ],
            category: "december"
        )
    }

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
