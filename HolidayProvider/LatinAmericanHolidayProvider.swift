//
//  LatinAmericanHolidayProvider.swift
//  MorningHello
//////
//  Created by Oxana Krylova on 22/09/2026.

import Foundation

struct LatinAmericanHolidayProvider {

    static func content(
        for date: Date = Date()
    ) -> HolidayContent? {

        var calendar = Calendar(
            identifier: .gregorian
        )
        calendar.timeZone = .current

        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }

        // MARK: - Карнавалы
        // Только 5–9 февраля 2027 года

        if year == 2027,
           month == 2,
           (5...9).contains(day) {

            let images = [
                "LA_holiday_1",
                "LA_holiday_2",
                "LA_holiday_3",
                "LA_holiday_4",
                "LA_holiday_5"
            ]

            let phrases = [
                "¡Que el carnaval llene tu día de alegría, música y color!",
                "¡Que hoy no falten el ritmo, las sonrisas y las ganas de celebrar!",
                "¡Vive la magia del carnaval con el corazón lleno de alegría!",
                "¡Que la energía del carnaval te acompañe y te regale momentos inolvidables!",
                "¡Feliz carnaval! Que cada instante esté lleno de fiesta, amistad y color."
            ]

            let index = day - 5

            return HolidayContent(
                images: [
                    images[index]
                ],
                phrases: [
                    phrases[index]
                ],
                category: "Праздники Латинской Америки"
            )
        }

        // MARK: - Инти Райми
        // Ежегодно 24 июня

        if month == 6 && day == 24 {
            return HolidayContent(
                images: [
                    "LA_holiday_6"
                ],
                phrases: [
                    "¡Feliz Inti Raymi! Que la luz del Sol renueve tu energía y llene tu vida de abundancia."
                ],
                category: "Праздники Латинской Америки"
            )
        }

        // MARK: - Día de los Muertos
        // Ежегодно 1–2 ноября

        if month == 11 && day == 1 {
            return HolidayContent(
                images: [
                    "LA_holiday_7"
                ],
                phrases: [
                    "En este Día de Muertos, celebremos con amor la vida y la memoria de quienes siguen viviendo en nuestros corazones."
                ],
                category: "Праздники Латинской Америки"
            )
        }

        if month == 11 && day == 2 {
            return HolidayContent(
                images: [
                    "LA_holiday_8"
                ],
                phrases: [
                    "Que las flores, las luces y los recuerdos llenen este Día de Muertos de amor y unión familiar."
                ],
                category: "Праздники Латинской Америки"
            )
        }

        // MARK: - Las Posadas
        // Ежегодно 16–24 декабря
        //
        // В периоде 9 дней, но создано 11 открыток.
        // Поэтому в каждый день приложение выбирает
        // одну открытку из всей коллекции.

        if month == 12,
           (16...24).contains(day) {

            return HolidayContent(
                images: [
                    "LA_holiday_9",
                    "LA_holiday_10",
                    "LA_holiday_11",
                    "LA_holiday_12",
                    "LA_holiday_13",
                    "LA_holiday_14",
                    "LA_holiday_15",
                    "LA_holiday_16",
                    "LA_holiday_17",
                    "LA_holiday_18",
                    "LA_holiday_19"
                ],
                phrases: [
                    "¡Felices Posadas! Que la esperanza ilumine tu hogar y reúna a quienes más quieres.",
                    "Que estas Posadas llenen tu casa de paz, alegría y cálidos encuentros.",
                    "¡Felices Posadas! Que cada noche traiga unión, generosidad y buenos deseos.",
                    "Que la luz de las velas guíe tus pasos y llene tu corazón de esperanza.",
                    "Que en estas Posadas nunca falten la amistad, la música y la alegría de compartir.",
                    "Que la piñata de la vida te regale salud, amor y muchas bendiciones.",
                    "¡Felices Posadas! Que tu hogar se llene de risas, cariño y momentos inolvidables.",
                    "Que esta celebración nos recuerde la importancia de abrir el corazón y compartir.",
                    "Que cada encuentro de las Posadas fortalezca los lazos con tu familia y tus amigos.",
                    "Te deseo unas Posadas llenas de luz, gratitud y esperanza.",
                    "Que la tradición de las Posadas lleve paz a tu hogar y alegría a tu corazón."
                ],
                category: "Праздники Латинской Америки"
            )
        }

        // MARK: - Navidad
        // Ежегодно 25 декабря

        if month == 12 && day == 25 {
            return HolidayContent(
                images: [
                    "LA_holiday_20"
                ],
                phrases: [
                    "¡Feliz Navidad! Que tu hogar se llene de amor, paz, salud y momentos felices junto a quienes más quieres."
                ],
                category: "Праздники Латинской Америки"
            )
        }

        return nil
    }
}
