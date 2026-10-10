//
//  MorningHello:EnglishPostcardLocalizer.swift
//  MorningHello
//
//  Created by Oxana Krylova on 16/09/2026.
//

import Foundation

enum EnglishPostcardLocalizer {

    private static let generalGreetings = [
        "Wishing you a calm morning and a day filled with warmth.",
        "May today bring you peace, kind moments, and good news.",
        "Wishing you good health, a light heart, and a beautiful day.",
        "May your day begin with a smile and unfold with ease.",
        "Sending you warm thoughts and wishes for a peaceful day.",
        "May there be comfort in your home and peace in your heart.",
        "Wishing you energy, inspiration, and plenty of reasons to smile.",
        "May today be gentle, bright, and full of pleasant surprises.",
        "Wishing you confidence, patience, and ease in everything you do.",
        "May this new day bring hope, warmth, and happy moments.",
        "Take good care of yourself and enjoy the little joys today.",
        "May every step you take today lead to something good.",
        "Wishing you clear thoughts, inner peace, and a joyful heart.",
        "May today bring you more smiles than worries.",
        "Wishing you a cozy morning and a successful day ahead.",
        "May your home be filled with harmony, warmth, and love.",
        "Wishing you a day of kind words and meaningful moments.",
        "May your dreams feel a little closer today.",
        "Wishing you strength for what matters and time for what brings you joy.",
        "May the care of those who love you warm your heart today.",
        "Wishing you peace of mind and light in your heart.",
        "May today leave you with beautiful memories.",
        "Trust the new day and look forward to something good.",
        "Wishing you warmth, comfort, and a wonderful sense of well-being."
    ]

    private static let birthdayGreetings = [
        "Happy birthday! Wishing you health, happiness, and a wonderful year ahead.",
        "May your birthday begin a year filled with joy, love, and success.",
        "Wishing you warm moments, good health, and many reasons to smile.",
        "May your dreams come true and every new day bring something beautiful.",
        "Happy birthday! May your life be filled with light, comfort, and kind people.",
        "Wishing you peace at home, joy in your heart, and only good news.",
        "May the year ahead bring delightful discoveries and many happy days.",
        "Happy birthday! May every year become brighter, kinder, and happier."
    ]

    private static let shabbatGreetings = [
        "Shabbat Shalom! May your home be filled with peace, warmth, and joy.",
        "May the Shabbat candles bring light, love, and blessing to your home.",
        "Wishing you a restful Shabbat filled with gratitude and inner peace.",
        "Shabbat Shalom! May your heart find rest and renewed strength for the week ahead.",
        "May this sacred day bring calm thoughts, family warmth, and quiet joy."
    ]

    static func localize(
        _ sourceText: String,
        category: String
    ) -> String {
        guard containsCyrillic(sourceText) else {
            return sourceText
        }

        let searchable = (sourceText + " " + category).lowercased()

        if category.lowercased().contains("birthday") ||
            searchable.contains("день рождения") {
            return pick(birthdayGreetings, for: sourceText)
        }

        if searchable.contains("шабат") ||
            searchable.contains("субботн") {
            return pick(shabbatGreetings, for: sourceText)
        }

        let holidayGreetings: [(needles: [String], text: String)] = [
            (["ханук"], "Happy Hanukkah! May the Festival of Lights fill your home with hope, warmth, and joy."),
            (["рош ха-шана", "рош ха шана"], "Shanah Tovah! Wishing you a sweet new year filled with health, peace, and happiness."),
            (["йом-кипур", "йом кипур"], "May this Yom Kippur bring reflection, peace, and a meaningful new beginning."),
            (["суккот"], "Chag Sukkot Sameach! May your home be filled with gratitude, hospitality, and joy."),
            (["песах"], "Happy Passover! Wishing you freedom, hope, and joyful moments with those you love."),
            (["пурим"], "Happy Purim! May your celebration be filled with joy, laughter, and kindness."),
            (["шавуот"], "Chag Shavuot Sameach! Wishing you a meaningful holiday filled with learning and joy."),
            (["ту би-шват", "ту би шват"], "Happy Tu BiShvat! May this new year of the trees bring renewal, growth, and hope."),
            (["симха тора"], "Chag Sameach! May Simchat Torah bring joy, inspiration, and a strong sense of community."),
            (["рождеств"], "Merry Christmas! May your home be filled with peace, love, and the warmth of the season."),
            (["пасх"], "Happy Easter! May this day bring renewed hope, peace, and joy to your heart."),
            (["троиц", "пятидесят"], "May this holy day bring faith, peace, and blessing to you and your loved ones."),
            (["благовещ"], "May the Feast of the Annunciation bring hope, peace, and joyful news."),
            (["крещен"], "May this holy day bring spiritual renewal, peace, and blessing."),
            (["вознесен"], "May the Feast of the Ascension fill your heart with faith, hope, and peace."),
            (["успен"], "May this sacred feast bring comfort, protection, and peace to your home."),
            (["новый год"], "Happy New Year! Wishing you health, peace, and many joyful moments in the year ahead."),
            (["день святого валентина"], "Happy Valentine's Day! Wishing you love, warmth, and caring people by your side."),
            (["день благодарения"], "Happy Thanksgiving! May your day be filled with gratitude, warmth, and time with loved ones."),
            (["день матери"], "Happy Mother's Day! Wishing you love, appreciation, and many warm moments."),
            (["день отца"], "Happy Father's Day! Wishing you love, appreciation, and a wonderful day."),
            (["8 марта", "женский день"], "Happy International Women's Day! Wishing you respect, joy, and inspiration."),
            (["хэллоуин"], "Happy Halloween! Wishing you a fun day filled with treats and delightful surprises."),
            (["день независимости"], "Happy Independence Day! Wishing you a joyful celebration with family and friends.")
        ]

        for item in holidayGreetings
        where item.needles.contains(where: searchable.contains) {
            return item.text
        }

        return pick(generalGreetings, for: sourceText)
    }

    private static func containsCyrillic(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x0400...0x04FF).contains(Int(scalar.value))
        }
    }

    private static func pick(
        _ values: [String],
        for sourceText: String
    ) -> String {
        let hash = sourceText.unicodeScalars.reduce(0) { partial, scalar in
            (partial &* 31 &+ Int(scalar.value)) & 0x7fffffff
        }

        return values[hash % values.count]
    }
}

