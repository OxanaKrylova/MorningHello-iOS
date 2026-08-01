//
//  JewishHolidayProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/08/2026.
//

import Foundation

struct JewishHolidayProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        /*
         Сначала проверяем праздники,
         для которых уже существуют отдельные провайдеры.
         */

        if let sukkot =
            SukkotPostcardProvider.content(
                for: date
            ) {

            return sukkot
        }

        if let hanukkah =
            HanukkahPostcardProvider.content(
                for: date
            ) {

            return hanukkah
        }

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

        // MARK: - Пурим

        if
            (year == 2026 && month == 3 && day == 3) ||
            (year == 2027 && month == 3 && day == 23) ||
            (year == 2028 && month == 3 && day == 12) {

            return HolidayContent(
                images: [
                    "holiday_purim"
                ],
                phrases: [
                    "С Пуримом! Пусть радость, свет и добро наполнят этот день!"
                ],
                category: "Еврейский"
            )
        }

        // MARK: - Песах

        if
            (year == 2026 &&
             month == 4 &&
             (2...9).contains(day)) ||

            (year == 2027 &&
             month == 4 &&
             (22...29).contains(day)) ||

            (year == 2028 &&
             month == 4 &&
             (11...18).contains(day)) {

            return HolidayContent(
                images: [
                    "holiday_Passover"
                ],
                phrases: [
                    "С Песахом! Пусть в доме будут свобода, мир и благословение!"
                ],
                category: "Еврейский"
            )
        }

        // MARK: - Лаг ба-Омер

        if
            (year == 2026 && month == 5 && day == 5) ||
            (year == 2027 && month == 5 && day == 25) ||
            (year == 2028 && month == 5 && day == 14) {

            return HolidayContent(
                images: [
                    "holiday_lagbaomer"
                ],
                phrases: [
                    "С Лаг ба-Омером! Пусть в сердце горит добрый свет!"
                ],
                category: "Еврейский"
            )
        }

        // MARK: - Тиша бе-Ав

        if
            (year == 2026 && month == 7 && day == 23) ||
            (year == 2027 && month == 8 && day == 12) ||
            (year == 2028 && month == 8 && day == 1) {

            return HolidayContent(
                images: [
                    "holiday_TishaBAv"
                ],
                phrases: [
                    "Пусть память о прошлом вдохновляет на надежду, мир и созидание."
                ],
                category: "Еврейский"
            )
        }

        // MARK: - Рош ха-Шана

        if
            (year == 2026 &&
             month == 9 &&
             (12...13).contains(day)) ||

            (year == 2027 &&
             month == 10 &&
             (2...3).contains(day)) ||

            (year == 2028 &&
             month == 9 &&
             (21...22).contains(day)) {

            return HolidayContent(
                images: [
                    "holiday_rosh"
                ],
                phrases: [
                    "С Рош ха-Шана! Сладкого, доброго и счастливого года!"
                ],
                category: "Еврейский"
            )
        }

        // MARK: - Йом-Кипур

        if
            (year == 2026 && month == 9 && day == 21) ||
            (year == 2027 && month == 10 && day == 11) ||
            (year == 2028 && month == 9 && day == 30) {

            return HolidayContent(
                images: [
                    "holiday_yom_kippor"
                ],
                phrases: [
                    "С Йом-Кипуром. Пусть этот день принесёт очищение, мир и свет душе."
                ],
                category: "Еврейский"
            )
        }

        // MARK: - Симхат-Тора

        if
            (year == 2026 && month == 10 && day == 4) ||
            (year == 2027 && month == 10 && day == 24) ||
            (year == 2028 && month == 10 && day == 13) {

            return HolidayContent(
                images: [
                    "holiday_Simha_Tora"
                ],
                phrases: [
                    "С Симхат-Тора! Пусть радость Торы освещает каждый день!"
                ],
                category: "Еврейский"
            )
        }

        return nil
    }
}
