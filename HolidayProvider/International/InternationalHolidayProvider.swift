//
//  InternationalHolidayProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 31/07/2026.
//

import Foundation

struct InternationalHolidayProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [.month, .day],
            from: date
        )

        guard let month = components.month,
              let day = components.day else {
            return nil
        }

        // Персеиды — 11, 12 и 13 августа.
        if month == 8 && (11...13).contains(day) {

            let imageIndex = day - 10

            return HolidayContent(
                images: [
                    "Holiday_Perceids_\(imageIndex)"
                ],
                phrases: [
                    "Пусть падающая звезда исполнит самое доброе желание.",
                    "Сегодня небо напоминает: чудеса случаются совсем рядом.",
                    "Пусть звёздный дождь принесёт надежду, спокойствие и вдохновение."
                ],
                category: "Персеиды"
            )
        }

        // Новый год — 31 декабря и 1 января.
        if (day == 31 && month == 12) ||
            (day == 1 && month == 1) {

            return HolidayContent(
                images: [
                    "holiday_new_year",
                    "holiday_new_year_2"
                ],
                phrases: [
                    "С Новым годом!",
                    "Пусть Новый год будет светлым и спокойным!"
                ],
                category: "Нейтральный"
            )
        }

        // День студента.
        if day == 25 && month == 1 {

            return HolidayContent(
                images: [
                    "holiday_student"
                ],
                phrases: [
                    "С Днём студента!",
                    "Помни, что знания открывают новые возможности!"
                ],
                category: "Нейтральный"
            )
        }

        // Всемирный день борьбы против рака.
        if day == 4 && month == 2 {

            return HolidayContent(
                images: [
                    "holiday_cancer"
                ],
                phrases: [
                    "Во Всемирный день борьбы против рака желаю крепкого здоровья!"
                ],
                category: "Нейтральный"
            )
        }

        // Международный день дружбы.
        if day == 30 && month == 7 {

            return HolidayContent(
                images: [
                    "holiday_friendship"
                ],
                phrases: [
                    "В Международный день дружбы желаю верных друзей, душевного тепла и радостных встреч!"
                ],
                category: "Нейтральный"
            )
        }

        // День рождения Гарри Поттера.
        if day == 31 && month == 7 {

            return HolidayContent(
                images: [
                    "holiday_Potter"
                ],
                phrases: [
                    "Пусть этот день будет наполнен волшебством, чудесами и добрыми приключениями!"
                ],
                category: "Нейтральный"
            )
        }
        
        // Международный день стоматолога.
        if day == 9 && month == 2 {

            return HolidayContent(
                images: [
                    "holiday_dentist"
                ],
                phrases: [
                    "С Международным днём стоматолога!"
                ],
                category: "Нейтральный"
            )
        }

        // День святого Валентина.
        if day == 14 && month == 2 {

            return HolidayContent(
                images: [
                    "holiday_valentine"
                ],
                phrases: [
                    "С Днём святого Валентина!",
                    "Пусть в сердце будет любовь и радость!"
                ],
                category: "Нейтральный"
            )
        }

        // Первый день весны.
        if day == 1 && month == 3 {

            return HolidayContent(
                images: [
                    "holiday_spring_beginning"
                ],
                phrases: [
                    "С первым днём весны!"
                ],
                category: "Нейтральный"
            )
        }

        // Всемирный день дикой природы.
        if day == 3 && month == 3 {

            return HolidayContent(
                images: [
                    "holiday_wild"
                ],
                phrases: [
                    "С Всемирным днём дикой природы!"
                ],
                category: "Нейтральный"
            )
        }

        // Международный женский день.
        if day == 8 && month == 3 {

            return HolidayContent(
                images: [
                    "holiday_womens_day"
                ],
                phrases: [
                    "С 8 Марта!",
                    "С Днем Весны и улыбок!"
                ],
                category: "Нейтральный"
            )
        }

        // День Земли.
        if day == 20 && month == 3 {

            return HolidayContent(
                images: [
                    "holiday_earth"
                ],
                phrases: [
                    "С Днём Земли!",
                    "Берегите наш общий дом!"
                ],
                category: "Нейтральный"
            )
        }

        // Весеннее равноденствие.
        if day == 22 && month == 3 {

            return HolidayContent(
                images: [
                    "holiday_vernal_equinox"
                ],
                phrases: [
                    "С Весенним равноденствием!"
                ],
                category: "Нейтральный"
            )
        }

        // День космонавтики.
        if day == 12 && month == 4 {

            return HolidayContent(
                images: [
                    "holiday_cosmonautics"
                ],
                phrases: [
                    "С Днём космонавтики!"
                ],
                category: "Нейтральный"
            )
        }

        // Праздник труда.
        if day == 1 && month == 5 {

            return HolidayContent(
                images: [
                    "holiday_labor_day"
                ],
                phrases: [
                    "Пусть май принесёт силы и радость!"
                ],
                category: "Нейтральный"
            )
        }

        // День Победы.
        if day == 9 && month == 5 {

            return HolidayContent(
                images: [
                    "holiday_victory"
                ],
                phrases: [
                    "С Днём Победы.",
                    "Пусть в сердцах всегда будут память, мир и благодарность."
                ],
                category: "Нейтральный"
            )
        }

        // День защиты детей.
        if day == 1 && month == 6 {

            return HolidayContent(
                images: [
                    "holiday_children"
                ],
                phrases: [
                    "С Днём защиты детей!"
                ],
                category: "Нейтральный"
            )
        }

        // День русского языка.
        if day == 6 && month == 6 {

            return HolidayContent(
                images: [
                    "holiday_RussianLanguage"
                ],
                phrases: [
                    "С Днём русского языка!"
                ],
                category: "Нейтральный"
            )
        }

        // Международный день собак.
        if day == 2 && month == 7 {

            return HolidayContent(
                images: [
                    "holiday_dog"
                ],
                phrases: [
                    "С Международным днём собак!"
                ],
                category: "Нейтральный"
            )
        }

        // День независимости США.
        if day == 4 && month == 7 {

            return HolidayContent(
                images: [
                    "holiday_USA"
                ],
                phrases: [
                    "С Днем независимости США!",
                    "Happy Independence Day!"
                ],
                category: "Нейтральный"
            )
        }

        // День взятия Бастилии.
        if day == 14 && month == 7 {

            return HolidayContent(
                images: [
                    "holiday_Bastilia"
                ],
                phrases: [
                    "С Днём взятия Бастилии!"
                ],
                category: "Нейтральный"
            )
        }

        // Всемирный день кошек.
        if day == 8 && month == 8 {

            return HolidayContent(
                images: [
                    "holiday_cat"
                ],
                phrases: [
                    "С Всемирным днём кошек!"
                ],
                category: "Нейтральный"
            )
        }

        // Начало учебного года.
        if day == 1 && month == 9 {

            return HolidayContent(
                images: [
                    "holiday_school_year"
                ],
                phrases: [
                    "С началом нового учебного года!"
                ],
                category: "Нейтральный"
            )
        }

        // Осеннее равноденствие.
        if day == 22 && month == 9 {

            return HolidayContent(
                images: [
                    "holiday_autumnal_equinox"
                ],
                phrases: [
                    "С Осенним равноденствием!"
                ],
                category: "Нейтральный"
            )
        }

        // День пожилых людей.
        if day == 1 && month == 10 {

            return HolidayContent(
                images: [
                    "holiday_elderly_day"
                ],
                phrases: [
                    "С Днём пожилых людей!",
                    "Желаю счастливых долгих лет жизни."
                ],
                category: "Нейтральный"
            )
        }

        // Всемирный день шопинга.
        if day == 11 && month == 11 {

            return HolidayContent(
                images: [
                    "holiday_shopping"
                ],
                phrases: [
                    "Сегодня - День шопинга!"
                ],
                category: "Нейтральный"
            )
        }

        // Первый день зимы.
        if day == 1 && month == 12 {

            return HolidayContent(
                images: [
                    "holiday_winter_beginning"
                ],
                phrases: [
                    "С первым днём зимы!"
                ],
                category: "Нейтральный"
            )
        }

        return nil
    }
}
