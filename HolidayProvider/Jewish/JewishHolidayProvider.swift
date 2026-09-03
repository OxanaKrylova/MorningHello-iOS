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

        // MARK: - День Алии
        // 7 хешвана:
        // 7 ноября 2027 года
        // 27 октября 2028 года
        // 16 октября 2029 года

        if
            (year == 2027 && month == 11 && day == 7) ||
            (year == 2028 && month == 10 && day == 27) ||
            (year == 2029 && month == 10 && day == 16) {

            return HolidayContent(
                images: [
                    "holiday_Aliyah"
                ],
                phrases: [
                    "С Днём Алии! Пусть Израиль станет тёплым домом, где встречаются надежда, поддержка и новые возможности."
                ],
                category: "Еврейский"
            )
        }

        return nil
    }

    // MARK: - Еврейские посты
  
    // MARK: - Еврейские посты

    static func fastContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        var hebrewCalendar = Calendar(
            identifier: .hebrew
        )

        hebrewCalendar.timeZone = .current

        let components = hebrewCalendar.dateComponents(
            [
                .year,
                .month,
                .day,
                .weekday
            ],
            from: date
        )

        guard let month = components.month,
              let day = components.day else {
            return nil
        }

        /*
         В Foundation Calendar(.hebrew):

         1  = Tishrei
         4  = Tevet
         7  = Adar / Adar II
         11 = Tammuz

         Это НЕ традиционная нумерация,
         где Nisan считается первым месяцем.
         */


        // 1. Пост Гедальи
        // 3 тишрея.
        //
        // Если 3 тишрея выпадает на Шаббат,
        // пост переносится на 4 тишрея.

        if month == 1 {

            if day == 3 {
                return HolidayContent(
                    images: [
                        "Judaism_FastGedaliah"
                    ],
                    phrases: [
                        "Пост Гедальи. Пусть этот день станет временем памяти, спокойных размышлений и внутреннего сосредоточения."
                    ],
                    category: "Еврейский"
                )
            }

            // Перенос с Шаббата:
            // если сегодня 4 тишрея и воскресенье.
            if day == 4,
               components.weekday == 1 {

                return HolidayContent(
                    images: [
                        "Judaism_FastGedaliah"
                    ],
                    phrases: [
                        "Пост Гедальи. Пусть этот день станет временем памяти, спокойных размышлений и внутреннего сосредоточения."
                    ],
                    category: "Еврейский"
                )
            }
        }


        // 2. Десятое тевета
        // 10 тевета

        if month == 4 &&
           day == 10 {

            return HolidayContent(
                images: [
                    "Judaism_TenthTevet"
                ],
                phrases: [
                    "Десятое тевета. Пусть этот день памяти и поста принесёт спокойствие, осмысленность и мир в сердце."
                ],
                category: "Еврейский"
            )
        }


        // 3. Семнадцатое тамуза
        // 17 тамуза.
        //
        // Если 17 тамуза приходится на Шаббат,
        // пост переносится на 18 тамуза.

        if month == 11 {

            if day == 17 {
                return HolidayContent(
                    images: [
                        "Judaism_SeventeenthTammuz"
                    ],
                    phrases: [
                        "Семнадцатое тамуза. Пусть этот день памяти станет временем тихих размышлений, терпения и внутренней силы."
                    ],
                    category: "Еврейский"
                )
            }

            // Перенос на воскресенье
            if day == 18,
               components.weekday == 1 {

                return HolidayContent(
                    images: [
                        "Judaism_SeventeenthTammuz"
                    ],
                    phrases: [
                        "Семнадцатое тамуза. Пусть этот день памяти станет временем тихих размышлений, терпения и внутренней силы."
                    ],
                    category: "Еврейский"
                )
            }
        }


        // 4. Пост Эстер
        // Обычно 13 адара.
        //
        // Если 13 адара приходится на Шаббат,
        // пост проводится заранее —
        // в четверг, 11 адара.

        if month == 7 {

            if day == 13 {
                return HolidayContent(
                    images: [
                        "Judaism_FastEsther"
                    ],
                    phrases: [
                        "Пост Эстер. Пусть этот день напомнит о силе веры, мужестве и надежде даже в непростые времена."
                    ],
                    category: "Еврейский"
                )
            }

            // Перенос на четверг перед Шаббатом
            if day == 11,
               components.weekday == 5 {

                return HolidayContent(
                    images: [
                        "Judaism_FastEsther"
                    ],
                    phrases: [
                        "Пост Эстер. Пусть этот день напомнит о силе веры, мужестве и надежде даже в непростые времена."
                    ],
                    category: "Еврейский"
                )
            }
        }


        return nil
    }
}
