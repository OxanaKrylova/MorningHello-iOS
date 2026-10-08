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

        let language = AppLanguage.selected

        let imagePrefix: String

        switch language {
        case .russian:
            imagePrefix = "December_"

        case .englishUS,
             .spanishLatinAmerica:
            imagePrefix = "DecemberUSA_"
        }

        let images = (1...26).map {
            "\(imagePrefix)\($0)"
        }

        let russianPhrases = [
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

        let englishPhrases = [
            "May this December morning bring warmth, comfort, and good news.",
            "Wishing you a bright day, peaceful thoughts, and lovely winter moments.",
            "May this December day be filled with care, joy, and heartfelt warmth.",
            "May it be chilly outside while warmth always stays in your heart.",
            "Wishing you a cozy morning, a cheerful mood, and little wishes coming true.",
            "May today give you a reason to smile and believe in good things.",
            "Wishing you warm meetings, kind words, and delightful winter wonders.",
            "May December fill your home with light, your heart with peace, and your day with joy.",
            "Wishing you a peaceful morning and a wonderful rest of the day.",
            "May the winter atmosphere bring inspiration, comfort, and peace of mind.",
            "May you be surrounded today by kind people and happy events.",
            "May this day be gentle, bright, and filled with pleasant moments.",
            "Wishing you winter comfort, heartfelt warmth, and a wonderful mood.",
            "May this morning become the beginning of a kind and happy day.",
            "Wishing you peace in your soul, warmth in your home, and joy in your heart.",
            "May this December day bring good news and pleasant surprises.",
            "Wishing you bright thoughts, warm meetings, and the feeling of wonder drawing near.",
            "May today bring you comfort, care, and sincere smiles.",
            "Wishing you a good morning and a day filled with warmth and gratitude.",
            "May this winter day leave time for rest, joy, and the people you love.",
            "May the cold remain outside while your home stays warm and peaceful.",
            "May this December morning bring hope, inspiration, and a cheerful mood.",
            "Wishing you a pleasant day, kind conversations, and happy moments.",
            "May this winter day be beautiful, cozy, and truly kind.",
            "Wishing you warmth in your heart, peace in your soul, and light in every moment.",
            "May today become another beautiful page in your winter story."
        ]

        let spanishPhrases = [
            "Que esta mañana de diciembre te traiga calidez, bienestar y buenas noticias.",
            "Te deseo un día luminoso, pensamientos tranquilos y agradables momentos de invierno.",
            "Que este día de diciembre esté lleno de cariño, alegría y calidez.",
            "Que el frío se quede afuera y la calidez permanezca siempre en tu corazón.",
            "Te deseo una mañana acogedora, buen ánimo y pequeños deseos cumplidos.",
            "Que hoy encuentres un motivo para sonreír y confiar en todo lo bueno.",
            "Te deseo encuentros cálidos, palabras amables y hermosas sorpresas de invierno.",
            "Que diciembre llene tu hogar de luz, tu corazón de paz y tu día de alegría.",
            "Te deseo una mañana tranquila y una maravillosa continuación del día.",
            "Que el ambiente invernal te brinde inspiración, bienestar y serenidad.",
            "Que hoy te rodeen personas amables y momentos felices.",
            "Que este día sea sereno, luminoso y lleno de momentos agradables.",
            "Te deseo bienestar invernal, calidez en el corazón y un ánimo maravilloso.",
            "Que esta mañana sea el comienzo de un día amable y feliz.",
            "Te deseo paz en el alma, calidez en el hogar y alegría en el corazón.",
            "Que este día de diciembre te traiga buenas noticias y agradables sorpresas.",
            "Te deseo pensamientos luminosos, encuentros cálidos y la emoción de una celebración cercana.",
            "Que hoy recibas cariño, bienestar y sonrisas sinceras.",
            "Te deseo buenos días y una jornada llena de calidez y gratitud.",
            "Que este día de invierno te deje tiempo para descansar, disfrutar y estar con quienes quieres.",
            "Que el frío se quede afuera y tu hogar permanezca cálido y tranquilo.",
            "Que esta mañana de diciembre te traiga esperanza, inspiración y buen ánimo.",
            "Te deseo un día agradable, conversaciones amables y momentos felices.",
            "Que este día de invierno sea hermoso, acogedor y verdaderamente amable.",
            "Te deseo calidez en el corazón, paz en el alma y luz en cada momento.",
            "Que hoy sea otra hermosa página de tu historia de invierno."
        ]

        let phrases: [String]

        switch language {
        case .russian:
            phrases = russianPhrases

        case .englishUS:
            phrases = englishPhrases

        case .spanishLatinAmerica:
            phrases = spanishPhrases
        }

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
