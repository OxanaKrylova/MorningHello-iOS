//
//  NovemberPostcardProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 15/08/2026.
//

import Foundation

struct NovemberPostcardProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [.month],
            from: date
        )

        guard let month = components.month,
              month == 11 else {
            return nil
        }

        let images = (1...21).map {
            "November_cat\($0)"
        }

        let phrases = [
            "Пусть ноябрьское утро будет тёплым, уютным и по-кошачьи спокойным.",
            "Желаю мягкого пледа, горячего чая и мурлыкающего счастья рядом.",
            "Пусть за окном будет прохладно, а дома всегда живут тепло и уют.",
            "Желаю доброго утра, спокойных мыслей и самого уютного ноября.",
            "Пусть сегодняшний день будет таким же тёплым и ласковым, как любимый кот.",
            "Желаю неспешного утра, душевного покоя и маленьких домашних радостей.",
            "Пусть ноябрь подарит больше уютных вечеров, тёплых встреч и счастливых мгновений.",
            "Желаю начать этот день с улыбки, чашки любимого напитка и хороших мыслей.",
            "Пусть сегодня найдётся время погреться, отдохнуть и просто побыть в уюте.",
            "Желаю, чтобы ноябрьская прохлада оставалась за окном, а в сердце было тепло.",
            "Пусть мурлыкающее настроение сопровождает вас с самого утра и до вечера.",
            "Желаю тёплого дома, спокойного сердца и добрых людей рядом.",
            "Пусть этот ноябрьский день будет мягким, неспешным и наполненным заботой.",
            "Желаю уютного утра, приятных новостей и пушистого хорошего настроения.",
            "Пусть сегодня вас согревают любимые люди, тёплые воспоминания и домашний уют.",
            "Желаю провести этот день без лишней суеты, с удовольствием и заботой о себе.",
            "Пусть ноябрьское утро подарит тепло, нежность и ощущение, что всё хорошо.",
            "Желаю маленьких радостей, больших чашек чая и уютных минут рядом с теми, кого любите.",
            "Пусть сегодняшний день будет добрым, спокойным и немного ленивым, как счастливый кот.",
            "Желаю вам тепла в доме, света в душе и поводов улыбнуться этому ноябрьскому дню.",
            "Пусть ноябрь напомнит, как приятно иногда никуда не спешить и просто наслаждаться уютом."
        ]

        let index = stableDailyIndex(
            count: images.count,
            salt: 1100,
            date: date
        )

        return HolidayContent(
            images: [images[index]],
            phrases: [phrases[index]],
            category: "Ноябрь"
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
