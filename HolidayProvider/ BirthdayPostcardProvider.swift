//
//   BirthdayPostcardProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/08/2026.
//

import Foundation

struct BirthdayPostcardProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        let savedDay = UserDefaults.standard.integer(
            forKey: "profile_birth_day"
        )

        let savedMonth = UserDefaults.standard.integer(
            forKey: "profile_birth_month"
        )

        // Дата рождения в профиле должна быть заполнена.
        guard savedDay > 0,
              savedMonth > 0 else {
            return nil
        }

        let calendar = Calendar.current

        let currentDay = calendar.component(
            .day,
            from: date
        )

        let currentMonth = calendar.component(
            .month,
            from: date
        )

        // Открытка показывается только в день рождения.
        guard currentDay == savedDay,
              currentMonth == savedMonth else {
            return nil
        }

        let savedName = UserDefaults.standard
            .string(
                forKey: "profile_display_name"
            )?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let greeting: String

        if let savedName,
           !savedName.isEmpty {

            greeting = """
            \(savedName), с днём рождения!

            Этот день — не про возраст, а про опыт, чувства, прожитые мгновения. Пусть он напомнит, как много уже пройдено и как много ещё впереди.

            Желаю, чтобы жизнь не уставала удивлять и радовать, чтобы были силы, вдохновение и желания. Чтобы всё хорошее, что ты даришь миру, возвращалось обратно.
            """

        } else {

            greeting = """
            С днём рождения!

            Этот день — не про возраст, а про опыт, чувства, прожитые мгновения. Пусть он напомнит, как много уже пройдено и как много ещё впереди.

            Желаю, чтобы жизнь не уставала удивлять и радовать, чтобы были силы, вдохновение и желания. Чтобы всё хорошее, что ты даришь миру, возвращалось обратно.
            """
        }

        return HolidayContent(
            images: [
                "holiday_birthday"
            ],
            phrases: [
                greeting
            ],
            category: "День рождения"
        )
    }
}
