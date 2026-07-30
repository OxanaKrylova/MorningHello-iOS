//
//  ContentView.swift
//  MorningHello
//
//  Oxana Krylova built this version 25-07-2026
//

import SwiftUI
import UIKit
import UserNotifications
import MessageUI
enum AppBackground: String {
    case morning = "Primary_background_Morning"
    case day = "Primary_Background_Day"
    case sunset = "Primary_Background_Sunset"
    case night = "Primary_Background_Night"

    static func current(for date: Date = Date()) -> AppBackground {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5..<12:
            // 05:00–11:59
            return .morning

        case 12..<18:
            // 12:00–17:59
            return .day

        case 18..<22:
            // 18:00–21:59
            return .sunset

        default:
            // 22:00–04:59
            return .night
        }
    }
}
struct ContentView: View {
    
    @State private var showContacts = false
    @State private var hasCheckedIn = false
    @State private var showShareSheet = false
    @State private var showHolidaySettings = false
    @State private var showProfile = false
    @State private var showPostcard = false
    @State private var hasEmergencyContacts = false
    @State private var showContactForWhatsApp = false
    @State private var showMessageComposer = false
    @State private var emergencyContactsForSharing: [EmergencyContact] = []
    @State private var shouldOpenEmergencyMessage = false
    @State private var showEmergencyMessageAlert = false
    @State private var showEmergencyContactSelection = false
    @State private var showSystemShareSheet = false
    @State private var showBirthdayGreeting = false
    
    @AppStorage("showOrthodoxHolidays") private var showOrthodoxHolidays = true
    @AppStorage("showCatholicHolidays") private var showCatholicHolidays = true
    @AppStorage("showJewishHolidays") private var showJewishHolidays = true
    @AppStorage("app_instance_id")
    private var appInstanceId: String = UUID().uuidString
    @AppStorage("checkInIntervalHours")
    private var checkInIntervalHours: Int = 48
    
    private let lastCheckInKey = "lastCheckInDate"
    
    struct SundayContent {
        let images: [String]
        let phrases: [String]
    }
    
    struct ShabbatContent {
        let image: String
        let phrase: String
    }
    
    @State private var lastCheckInDate: Date?
    func stableDailyIndex(
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
    var isCheckInBlocked: Bool {
        guard let lastCheckInDate else {
            return false
        }
        
        return Date().timeIntervalSince(lastCheckInDate) < 24 * 60 * 60
    }
    
    private let phrases = [
        "Доброе утро! Пусть день будет светлым и спокойным.",
        "С новым днём! Пусть сегодня всё сложится наилучшим образом.",
        "Просыпайся с улыбкой — и день улыбнётся тебе в ответ.",
        "Доброго утра и крепкого здоровья!",
        "Пусть утреннее солнце согреет душу и сердце.",
        "Хорошего настроения на весь день!",
        "Пусть в доме будет тепло, а в душе — мир.",
        "Утро начинается с хороших мыслей — пусть они будут добрыми.",
        "Желаю бодрости, сил и радости на весь день.",
        "Пусть каждый час сегодня принесёт что-то хорошее.",
        "Доброе утро! Пусть ангел хранит тебя сегодня.",
        "Мира, добра и спокойствия в этот день.",
        "Пусть всё задуманное получится легко и радостно.",
        "Улыбнись новому дню — он уже пришёл к тебе.",
        "Доброго утра и благословенного дня!",
        "Пусть чашка утреннего чая принесёт уют и тепло.",
        "Солнечного настроения и добрых встреч!",
        "Пусть здоровье не подводит, а счастье будет рядом.",
        "Начни день с благодарности — и он будет щедрым.",
        "Пусть этот день подарит спокойствие и свет в сердце.",
        "Доброе утро! Пусть сегодняшний день подарит тебе радость и спокойствие.",
        "Пусть новый день начнётся с улыбки и приятных мыслей.",
        "Желаю тебе бодрого утра и прекрасного настроения.",
        "Пусть сегодня всё складывается легко и удачно.",
        "Доброе утро! Верь в себя, и у тебя всё получится.",
        "Пусть этот день принесёт добрые новости и тёплые встречи.",
        "Желаю тебе сил, вдохновения и душевного тепла.",
        "Пусть утро наполнит сердце надеждой и светом.",
        "Начни этот день с улыбки и ожидания хорошего.",
        "Пусть сегодня рядом будут забота, любовь и понимание.",
        "Доброе утро! Желаю тебе спокойного и счастливого дня.",
        "Пусть каждый сегодняшний момент приносит радость.",
        "Желаю тебе здоровья, бодрости и хороших мыслей.",
        "Пусть новый день откроет перед тобой новые возможности.",
        "Доброе утро! Пусть всё задуманное обязательно исполнится.",
        "Пусть сегодняшний день будет добрым к тебе.",
        "Желаю тебе уверенности, терпения и лёгкости во всех делах.",
        "Пусть утренний свет наполнит душу теплом.",
        "Доброе утро! Сегодня обязательно произойдёт что-то хорошее.",
        "Пусть этот день будет спокойным, светлым и радостным.",
        "Желаю тебе приятных событий и искренних улыбок.",
        "Пусть сегодня у тебя найдётся повод для радости.",
        "Доброе утро! Сделай шаг навстречу своей мечте.",
        "Пусть новый день подарит тебе силы двигаться вперёд.",
        "Желаю тебе гармонии в душе и удачи во всех начинаниях.",
        "Пусть сегодня всё получается с первого раза.",
        "Доброе утро! Ты сильнее, чем тебе иногда кажется.",
        "Пусть этот день принесёт тебе уверенность и вдохновение.",
        "Желаю тебе лёгкого утра и доброго продолжения дня.",
        "Пусть в твоём сердце сегодня живут мир и благодарность.",
        "Доброе утро! Не забывай замечать маленькие радости.",
        "Пусть сегодняшний день станет началом чего-то прекрасного.",
        "Желаю тебе тепла, уюта и хорошего самочувствия.",
        "Пусть каждое дело сегодня приносит удовлетворение.",
        "Доброе утро! Впереди новый день и новые возможности.",
        "Пусть сегодня тебя окружают только добрые люди.",
        "Желаю тебе ясных мыслей и спокойствия в сердце.",
        "Пусть этот день подарит тебе больше улыбок, чем забот.",
        "Доброе утро! Сохраняй надежду и верь в лучшее.",
        "Пусть сегодня тебе сопутствуют удача и хорошее настроение.",
        "Желаю тебе вдохновения для новых идей и свершений.",
        "Пусть утро будет уютным, а день — успешным.",
        "Доброе утро! Отпусти тревоги и впусти в сердце свет.",
        "Пусть сегодняшний день принесёт приятные перемены.",
        "Желаю тебе душевного равновесия и крепкого здоровья.",
        "Пусть каждый шаг сегодня ведёт тебя к хорошему.",
        "Доброе утро! Ты достоин счастья, заботы и любви.",
        "Пусть новый день наполнит твою жизнь яркими красками.",
        "Желаю тебе терпения, мудрости и внутренней силы.",
        "Пусть сегодня в твоём доме царят уют и согласие.",
        "Доброе утро! Начинай день с веры в себя.",
        "Пусть всё важное сегодня решится благополучно.",
        "Желаю тебе спокойного сердца и уверенных решений.",
        "Пусть этот день будет наполнен добрыми словами.",
        "Доброе утро! Не бойся начинать что-то новое.",
        "Пусть сегодня мечты станут немного ближе.",
        "Желаю тебе радости от каждого прожитого мгновения.",
        "Пусть новый день принесёт тебе ощущение счастья.",
        "Доброе утро! Благодари жизнь за всё хорошее.",
        "Пусть сегодня у тебя будет достаточно сил для всего важного.",
        "Желаю тебе приятного общения и добрых новостей.",
        "Пусть этот день пройдёт легко и без лишних тревог.",
        "Доброе утро! Смотри вперёд с надеждой и уверенностью.",
        "Пусть сегодняшний день согреет тебя заботой близких.",
        "Желаю тебе успеха во всех делах и начинаниях.",
        "Пусть утро подарит тебе бодрость и ясность мыслей.",
        "Доброе утро! Каждый новый день — это новый шанс.",
        "Пусть сегодня тебе встретится много хорошего.",
        "Желаю тебе мира в душе и света в сердце.",
        "Пусть этот день оставит после себя добрые воспоминания.",
        "Доброе утро! Помни, что даже маленький шаг ведёт вперёд.",
        "Пусть сегодня всё происходит в нужное время.",
        "Желаю тебе спокойствия, радости и душевного комфорта.",
        "Пусть новый день поможет поверить в собственные силы.",
        "Доброе утро! Открой сердце навстречу хорошим событиям.",
        "Пусть сегодня тебя ждут приятные сюрпризы.",
        "Желаю тебе здоровья, энергии и прекрасного настроения.",
        "Пусть каждый час этого дня будет наполнен смыслом.",
        "Доброе утро! Ты способен справиться со всеми трудностями.",
        "Пусть сегодня в твоей жизни станет немного больше света.",
        "Желаю тебе лёгкости в делах и тепла в общении.",
        "Пусть этот день принесёт гармонию и внутренний покой.",
        "Доброе утро! Доверься новому дню и жди хорошего.",
        "Пусть сегодня всё вокруг напоминает тебе о красоте жизни.",
        "Желаю тебе уверенно идти к своим целям.",
        "Пусть утро начнётся спокойно, а день продолжится радостно.",
        "Доброе утро! Береги себя и своё хорошее настроение.",
        "Пусть сегодняшний день подарит тебе вдохновение.",
        "Желаю тебе добрых мыслей и счастливых минут.",
        "Пусть новый день принесёт уют, надежду и любовь.",
        "Доброе утро! Пусть твоя улыбка сделает мир немного светлее.",
        "Пусть сегодня рядом окажутся люди, которые тебя ценят.",
        "Желаю тебе благополучия, спокойствия и душевных сил.",
        "Пусть этот день станет ещё одной доброй страницей твоей жизни.",
        "Доброе утро! Всё хорошее обязательно найдёт дорогу к тебе.",
        "Пусть сегодня сердце будет лёгким, а мысли — светлыми.",
        "Желаю тебе прекрасного дня, наполненного радостью.",
        "Пусть новый день подарит тебе веру в лучшее.",
        "Доброе утро! Пусть каждый момент сегодня будет особенным.",
        "Пусть сегодняшний день принесёт мир, тепло и счастье."
    ]
    
    private let images = [
        "autumn_friday", "autumn_monday", "autumn_saturday", "autumn_thursday", "autumn_tuesday", "autumn_wednesday",
        "spring_friday", "spring_monday", "spring_saturday", "spring_thursday", "spring_tuesday", "spring_wednesday",
        "summer_friday", "summer_monday", "summer_saturday", "summer_thursday", "summer_tuesday", "summer_wednesday",
        "winter_friday", "winter_monday", "winter_saturday", "winter_thursday", "winter_tuesday", "winter_wednesday"
    ]
    func checkEmergencyContacts() {
        guard let data = UserDefaults.standard.data(
            forKey: "emergency_contacts"
        ) else {
            hasEmergencyContacts = false
            return
        }
        
        guard let savedContacts = try? JSONDecoder().decode(
            [EmergencyContact].self,
            from: data
        ) else {
            hasEmergencyContacts = false
            return
        }
        
        hasEmergencyContacts = !savedContacts.isEmpty
    }
    private func createBackendPayload(
        checkInDate: Date
    ) -> UserStatusPayload {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        let contactPayloads = loadContactsForSharing().map { contact in
            EmergencyContactPayload(
                firstName: contact.name,
                lastName: contact.surname,
                phone: contact.phoneDigits,
                email: contact.email
            )
        }
        
        let lastCheckInPayload = LastCheckInPayload(
            timestamp: formatter.string(from: checkInDate),
            timezone: TimeZone.current.identifier
        )
        
        let appVersion =
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "1.0.0"
        
        let userPayload = UserProfilePayload(
            name: profileDisplayName
        )
        
        return UserStatusPayload(
            appInstanceId: appInstanceId,
            appVersion: appVersion,
            status: "alive",
            user: userPayload,
            lastCheckIn: lastCheckInPayload,
            checkInIntervalHours: checkInIntervalHours,
            emergencyContacts: contactPayloads
        )
    }
    private func createBackendJSON(
        checkInDate: Date
    ) -> Data? {
        
        let payload = createBackendPayload(
            checkInDate: checkInDate
        )
        
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        
        do {
            return try encoder.encode(payload)
        } catch {
            print(
                "Ошибка формирования JSON:",
                error.localizedDescription
            )
            
            return nil
        }
    }
    
    func loadContactsForSharing() -> [EmergencyContact] {
        guard let data = UserDefaults.standard.data(
            forKey: "emergency_contacts"
        ),
              let contacts = try? JSONDecoder().decode(
                [EmergencyContact].self,
                from: data
              ) else {
            return []
        }
        
        return contacts
    }
    
    func normalizedPhone(_ phone: String) -> String {
        phone.filter { $0.isNumber }
    }
    private var postcardShareText: String {
        let greeting: String
        
        if profileDisplayName.isEmpty {
            greeting = "Желаю вам доброго утра!"
        } else {
            greeting = "\(profileDisplayName) желает вам доброго утра!"
        }
        
        return greeting + "\n\n" + smartPhrase
    }
    
    func openMessages() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        
        showMessageComposer = true
    }
    var profileDisplayName: String {
        let savedName = UserDefaults.standard.string(
            forKey: "profile_display_name"
        )?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let savedName, !savedName.isEmpty else {
            return ""
        }
        
        return savedName
    }

    func birthdayContent(for date: Date = Date()) -> HolidayContent? {
        let defaults = UserDefaults.standard
        
        guard let birthday = defaults.object(
            forKey: "profile_birthday"
        ) as? Date else {
            return nil
        }
        
        let calendar = Calendar.current
        
        let todayComponents = calendar.dateComponents(
            [.month, .day],
            from: date
        )
        
        let birthdayComponents = calendar.dateComponents(
            [.month, .day],
            from: birthday
        )
        
        guard todayComponents.month == birthdayComponents.month,
              todayComponents.day == birthdayComponents.day else {
            return nil
        }
        
        return HolidayContent(
            images: [
                "holiday_birthday"
            ],
            phrases: [
                "С днём рождения! Пусть этот день будет наполнен теплом, радостью и заботой близких."
            ],
            category: "День рождения"
        )
    }

    func birthdayContent() -> HolidayContent? {
        let savedDay = UserDefaults.standard.integer(
            forKey: "profile_birth_day"
        )
        
        let savedMonth = UserDefaults.standard.integer(
            forKey: "profile_birth_month"
        )
        
        guard savedDay > 0, savedMonth > 0 else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        let currentDay = calendar.component(.day, from: today)
        let currentMonth = calendar.component(.month, from: today)
        
        guard currentDay == savedDay,
              currentMonth == savedMonth else {
            return nil
        }
        
        let savedName = UserDefaults.standard
            .string(forKey: "profile_display_name")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let greeting: String
        
        if let savedName, !savedName.isEmpty {
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
            images: ["holiday_birthday"],
            phrases: [greeting],
            category: "Нейтральный"
        )
    }
    func currentShabbatContent(
        for date: Date = Date()
    ) -> ShabbatContent? {
        
        // Шабатные открытки показываются только тогда,
        // когда пользователь включил еврейские праздники.
        guard showJewishHolidays else {
            return nil
        }
        
        guard let shabbatStart = shabbatStartDate(for: date) else {
            return nil
        }
        
        let shabbatImages = [
            "Shabbat_1",
            "Shabbat_2",
            "Shabbat_3",
            "Shabbat_4",
            "Shabbat_5",
            "Shabbat_6",
            "Shabbat_7",
            "Shabbat_8",
            "Shabbat_9",
            "Shabbat_10",
            "Shabbat_11"
        ]
        
        let shabbatPhrases = [
            "Шабат Шалом! Пусть этот святой день наполнит ваш дом миром, сердца — покоем, а душу — светлой радостью.",
            
            "Пусть огонь субботних свечей принесёт в ваш дом тепло, любовь, взаимопонимание и Божье благословение.",
            
            "Мир вашему дому! Пусть шабат станет временем отдыха, добрых разговоров, любви и внутренней гармонии.",
            
            "Шабат Шалом! Пусть в этот день каждый найдёт покой для души, радость для сердца и силы для новой недели.",
            
            "Пусть субботние свечи освещают не только ваш дом, но и каждый следующий день вашей жизни. Мирного шабата!",
            
            "Пусть этот святой день принесёт покой мыслям, тепло душе и радость каждому, кто вам дорог.",
            
            "Желаю светлого шабата! Пусть в доме всегда царят согласие, достаток, здоровье и семейное счастье.",
            
            "Пусть субботний вечер наполнится теплом свечей, ароматом праздничного стола и искренними улыбками родных.",
            
            "Шабат Шалом! Пусть всё добро, которое вы дарите другим, возвращается к вам сторицей.",
            
            "Желаю провести этот шабат в мире, любви и благодарности. Пусть сердце отдыхает, а душа наполняется светом.",
            
            "Желаю спокойного шабата. Пусть этот день станет маленьким островком света, добра и душевного равновесия."
        ]
        
        let availableCount = min(
            shabbatImages.count,
            shabbatPhrases.count
        )
        
        guard availableCount > 0 else {
            return nil
        }
        
        // Расчёт выполняется от пятницы 18:00.
        // Поэтому в пятницу и субботу индекс будет одинаковым.
        let index = stableDailyIndex(
            count: availableCount,
            salt: 900,
            date: shabbatStart
        )
        
        return ShabbatContent(
            image: shabbatImages[index],
            phrase: shabbatPhrases[index]
        )
    }
    private func sundayContent(
        date: Date = Date()
    ) -> HolidayContent? {
        SundayPostcardProvider.content(
            for: date
        )
    }
    
    func decemberContent(
        date: Date = Date()
    ) -> HolidayContent? {
        DecemberPostcardProvider.content(
            for: date
        )
    }
    private func februaryContent(
        date: Date = Date()
    ) -> HolidayContent? {
        FebruaryPostcardProvider.content(
            for: date
        )
    }
    private func mondayCoffeeContent(
        date: Date = Date()
    ) -> HolidayContent? {
        MondayPostcardProvider.content(
            for: date
        )
    }
    private func hanukkahContent(
        date: Date = Date()
    ) -> HolidayContent? {

        guard showJewishHolidays else {
            return nil
        }

        return HanukkahPostcardProvider.content(
            for: date
        )
    }
    func currentWeekday() -> String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch weekday {
        case 1: return "sunday"
        case 2: return "monday"
        case 3: return "tuesday"
        case 4: return "wednesday"
        case 5: return "thursday"
        case 6: return "friday"
        case 7: return "saturday"
        default: return "monday"
        }
    }
    
    func currentSeason() -> String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 12, 1, 2: return "winter"
        case 3, 4, 5: return "spring"
        case 6, 7, 8: return "summer"
        case 9, 10, 11: return "autumn"
        default: return "winter"
        }
    }
    private func catholicEasterDate(
        for year: Int
    ) -> Date? {
        
        let easterDates: [Int: (day: Int, month: Int)] = [
            2026: (5, 4),
            2027: (28, 3),
            2028: (16, 4)
        ]
        
        guard let easter = easterDates[year] else {
            return nil
        }
        
        var components = DateComponents()
        components.year = year
        components.month = easter.month
        components.day = easter.day
        components.hour = 12
        
        return Calendar.current.date(
            from: components
        )
    }
    private func catholicHolyWeekContent(
        date: Date = Date()
    ) -> HolidayContent? {
        
        let calendar = Calendar.current
        
        let year = calendar.component(
            .year,
            from: date
        )
        
        guard let easterDate =
                catholicEasterDate(for: year) else {
            return nil
        }
        
        let currentDay = calendar.startOfDay(
            for: date
        )
        
        let easterDay = calendar.startOfDay(
            for: easterDate
        )
        
        guard let difference = calendar.dateComponents(
            [.day],
            from: currentDay,
            to: easterDay
        ).day else {
            return nil
        }
        
        let commonPhrases = [
            "Пусть эти святые дни принесут душевный покой, надежду и внутренний свет.",
            "Желаю мира в сердце, добрых мыслей и тихой радости в ожидании Пасхи.",
            "Пусть вера, любовь и надежда поддерживают вас и ваших близких.",
            "Пусть этот день наполнится молитвой, спокойствием и добрыми поступками.",
            "Желаю душевного равновесия, мира в доме и Божьего благословения."
        ]
        
        let phraseIndex = stableDailyIndex(
            count: commonPhrases.count,
            salt: 1300,
            date: date
        )
        
        let phrase = commonPhrases[phraseIndex]
        
        switch difference {
            
            // Понедельник перед Пасхой
        case 6:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Monday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )
            
            // Вторник перед Пасхой
        case 5:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Tuesday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )
            
            // Среда перед Пасхой
        case 4:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Wednesday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )
            
            // Великий четверг
        case 3:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Thursday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )
            
            // Страстная пятница
        case 2:
            return HolidayContent(
                images: [
                    "Catholic_Good_Friday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )
            
            // Великая суббота
        case 1:
            return HolidayContent(
                images: [
                    "Catholic_Holy_Saturday"
                ],
                phrases: [
                    phrase
                ],
                category: "Католический"
            )
            
            // Католическая Пасха
        case 0:
            let easterPhrases = [
                "Христос воскрес! Пусть Пасха наполнит ваш дом светом, любовью и надеждой.",
                "Со Светлой Пасхой! Желаю мира, здоровья и благополучия вашей семье.",
                "С Пасхой Христовой! Пусть радость Воскресения согревает сердца ваших близких."
            ]
            
            let easterPhraseIndex = stableDailyIndex(
                count: easterPhrases.count,
                salt: 1310,
                date: date
            )
            
            return HolidayContent(
                images: [
                    "holiday_catholic_passover"
                ],
                phrases: [
                    easterPhrases[easterPhraseIndex]
                ],
                category: "Католический"
            )
            
        default:
            return nil
        }
    }
    private func pancakeDayContent(
        date: Date = Date()
    ) -> HolidayContent? {
        
        let calendar = Calendar.current
        let year = calendar.component(
            .year,
            from: date
        )
        
        guard let easterDate = catholicEasterDate(
            for: year
        ),
              let pancakeDayDate = calendar.date(
                byAdding: .day,
                value: -47,
                to: easterDate
              ) else {
            return nil
        }
        
        guard calendar.isDate(
            date,
            inSameDayAs: pancakeDayDate
        ) else {
            return nil
        }
        
        return HolidayContent(
            images: [
                "Holiday_PancakeDay"
            ],
            phrases: [
                "С Блинным днём! Пусть этот день будет тёплым, вкусным и наполненным радостью.",
                "С Pancake Day! Желаю уютного дня, добрых встреч и самых вкусных блинов.",
                "Пусть Блинный день подарит хорошее настроение, домашнее тепло и приятные моменты.",
                "С Блинным днём! Пусть в доме пахнет блинами, а рядом будут любимые люди."
            ],
            category: "Католический"
        )
    }
    private func orthodoxEasterDate(
        for year: Int
    ) -> Date? {
        
        let easterDates: [Int: (day: Int, month: Int)] = [
            2026: (12, 4),
            2027: (2, 5),
            2028: (16, 4),
            2029: (8, 4),
            2030: (28, 4)
        ]
        
        guard let easter = easterDates[year] else {
            return nil
        }
        
        var components = DateComponents()
        components.year = year
        components.month = easter.month
        components.day = easter.day
        components.hour = 12
        
        return Calendar.current.date(
            from: components
        )
    }
    
    private func orthodoxHolyWeekContent(
        date: Date = Date()
    ) -> HolidayContent? {
        
        let calendar = Calendar.current
        let year = calendar.component(
            .year,
            from: date
        )
        
        guard let easterDate =
                orthodoxEasterDate(for: year) else {
            return nil
        }
        
        let currentDay = calendar.startOfDay(
            for: date
        )
        
        let easterDay = calendar.startOfDay(
            for: easterDate
        )
        
        guard let difference = calendar.dateComponents(
            [.day],
            from: currentDay,
            to: easterDay
        ).day else {
            return nil
        }
        
        switch difference {
            
            // Понедельник перед Пасхой
        case 6:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Monday"
                ],
                phrases: [
                    "Пусть начало Страстной недели принесёт тишину в сердце, ясность мыслей и душевный покой."
                ],
                category: "Православный"
            )
            
            // Вторник перед Пасхой
        case 5:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Tuesday"
                ],
                phrases: [
                    "Пусть этот день станет временем добрых мыслей, искренней молитвы и внутреннего света."
                ],
                category: "Православный"
            )
            
            // Среда перед Пасхой
        case 4:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Wednesday"
                ],
                phrases: [
                    "Желаю душевного спокойствия, терпения и сил пройти эти особенные дни с верой и любовью."
                ],
                category: "Православный"
            )
            
            // Чистый четверг
        case 3:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Thursday"
                ],
                phrases: [
                    "В Чистый четверг пусть в доме будет мир, в мыслях — чистота, а в сердце — любовь и надежда."
                ],
                category: "Православный"
            )
            
            // Страстная пятница
        case 2:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Friday"
                ],
                phrases: [
                    "Пусть Страстная пятница наполнит сердце смирением, состраданием и тихой надеждой."
                ],
                category: "Православный"
            )
            
            // Великая суббота
        case 1:
            return HolidayContent(
                images: [
                    "Orthodox_Holy_Saturday"
                ],
                phrases: [
                    "Пусть Великая суббота пройдёт в мире, тишине и ожидании светлой пасхальной радости."
                ],
                category: "Православный"
            )
            
            // Пасхальное воскресенье
        case 0:
            let easterPhrases = [
                "Христос воскрес! Пусть этот день наполнит ваш дом уютом, а сердце — любовью и покоем.",
                "Христос воскрес! Желаю вашей семье крепкого здоровья, благополучия и чтобы каждый день был согрет Божьим благословением.",
                "Со Светлой Пасхой! Желаю, чтобы в жизни было побольше светлых моментов, гармонии и добра.",
                "Со Светлой Пасхой! Пусть рядом всегда будут люди, с которыми тепло и радостно!",
                "Со светлым праздником Пасхи! Мира, душевного спокойствия, и пусть всё задуманное обязательно сбудется!"
            ]
            
            let phraseIndex = stableDailyIndex(
                count: easterPhrases.count,
                salt: 1200,
                date: date
            )
            
            return HolidayContent(
                images: [
                    "holiday_easter"
                ],
                phrases: [
                    easterPhrases[phraseIndex]
                ],
                category: "Православный"
            )
            
        default:
            return nil
        }
    }
    private func forgivenSundayContent(
        date: Date = Date()
    ) -> HolidayContent? {
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        guard let easterDate = orthodoxEasterDate(
            for: year
        ),
              let forgivenSundayDate = calendar.date(
                byAdding: .day,
                value: -56,
                to: easterDate
              ) else {
            return nil
        }
        
        guard calendar.isDate(
            date,
            inSameDayAs: forgivenSundayDate
        ) else {
            return nil
        }
        
        return HolidayContent(
            images: [
                "Holiday_ForgivenSunday"
            ],
            phrases: [
                "В Прощёное воскресенье прошу прощения за всё и желаю мира, добра и душевного спокойствия."
            ],
            category: "Православный"
        )
    }
    func holidayContent() -> HolidayContent? {
        let calendar = Calendar.current
        let today = Date()
        
        let day = calendar.component(.day, from: today)
        let month = calendar.component(.month, from: today)
        let weekday = calendar.component(.weekday, from: today)
        let weekOfMonth = calendar.component(.weekOfMonth, from: today)
        let year = calendar.component(.year, from: today)
        
        // Страстная неделя и православная Пасха.
        if let holyWeekContent = orthodoxHolyWeekContent(
            date: today
        ) {
            return holyWeekContent
        }
        
        // Католическая Страстная неделя и Пасха.
        if let catholicHolyWeek =
            catholicHolyWeekContent(date: today) {
            
            return catholicHolyWeek
        }
        // Прощёное воскресенье.
        if let forgivenSunday =
            forgivenSundayContent(date: today) {
            
            return forgivenSunday
        }
        // Pancake Day — за 47 дней до католической Пасхи.
        if let pancakeDay =
            pancakeDayContent(date: today) {
            
            return pancakeDay
        }
        if let internationalHoliday =
            InternationalHolidayProvider.content(
                for: today
            ) {

            return internationalHoliday
        }
        
        if day == 7 && month == 1 {
            return HolidayContent(images: ["holiday_orthodox_christmas"], phrases: ["С Рождеством Христовым!", "Пусть свет Рождества наполнит ваш дом любовью, миром и Божией благодатью."], category: "Православный")
        }
        
        if day == 19 && month == 1 {
            return HolidayContent(images: ["holiday_epiphany"], phrases: ["С Крещением!", "Пусть в душе будет свет и мир!"], category: "Православный")
        }
        
        if day == 17 && month == 3 {
            return HolidayContent(images: ["holiday_Patrick"], phrases: ["С Днём святого Патрика!", "Пусть удача, радость и добро будут рядом!"], category: "Католический")
        }
        
        if day == 7 && month == 4 {
            return HolidayContent(images: ["holiday_annunciation"], phrases: ["С Благовещением!", "Пусть этот день принесёт добрые вести!"], category: "Православный")
        }
        
        if day == 7 && month == 7 {
            return HolidayContent(images: ["holiday_kupalo"], phrases: ["С праздником Ивана Купалы!", "С Днём Ивана Купалы!"], category: "Православный")
        }
        
        // 24 июня — Рождество святого Иоанна Крестителя.
        if day == 24 && month == 6 {
            return HolidayContent(
                images: [
                    "Holiday_LaSaint_Jean"
                ],
                phrases: [
                    "С днём святого Иоанна Крестителя! Пусть вера, надежда и внутренний свет всегда помогают идти правильной дорогой."
                ],
                category: "Католический"
            )
        }
        // Преображение Господне (католическое)
        if month == 8 && day == 6 {
            return HolidayContent(
                images: [
                    "Holiday_Tranfiguration"
                ],
                phrases: [
                    "С праздником Преображения Господня! Пусть свет Христов озаряет ваш путь, наполняя сердце миром, надеждой и любовью.",
                    "В день Преображения Господня желаю духовной радости, крепкой веры и Божьего благословения.",
                    "Пусть праздник Преображения напоминает о силе света, добра и любви, преображающих нашу жизнь."
                ],
                category: "Католический"
            )
        }
        // Яблочный Спас
        if month == 8 && day == 19 {
            return HolidayContent(
                images: [
                    "Holiday_Apple"
                ],
                phrases: [
                    "С Яблочным Спасом! Пусть Господь благословит ваш дом, подарит здоровье, мир и добрые плоды ваших трудов.",
                    "Поздравляю с Яблочным Спасом! Желаю душевного тепла, семейного счастья и Божией благодати.",
                    "Пусть Яблочный Спас наполнит сердце благодарностью, дом — достатком, а каждый день — радостью и светом."
                ],
                category: "Православный"
            )
        }
        if day == 15 && month == 2 {
            return HolidayContent(
                images: ["holiday_meeting"],
                phrases: [
                    "Со Сретением Господним!"
                ],
                category: "Православный"
            )
        }
        
        if let orthodoxEaster = orthodoxEasterDate(for: year),
           let palmSundayDate = Calendar.current.date(
            byAdding: .day,
            value: -7,
            to: orthodoxEaster
           ) {
            
            let palmSundayDay = Calendar.current.component(
                .day,
                from: palmSundayDate
            )
            
            let palmSundayMonth = Calendar.current.component(
                .month,
                from: palmSundayDate
            )
            
            if day == palmSundayDay && month == palmSundayMonth {
                return HolidayContent(
                    images: ["holiday_palm_sunday"],
                    phrases: [
                        "С Вербным воскресеньем!"
                    ],
                    category: "Православный"
                )
            }
        }
        
        if day == 8 && month == 7 {
            return HolidayContent(images: ["holiday_family_love"], phrases: ["С Днём семьи, любви и верности!", "Пусть в доме всегда будут любовь, тепло и согласие!"], category: "Православный")
        }
        
        if day == 28 && month == 7 {
            return HolidayContent(images: ["holiday_baptism"], phrases: ["С Днём крещения Руси!"], category: "Православный")
        }
        
        if day == 28 && month == 8 {
            return HolidayContent(images: ["holiday_dormition"], phrases: ["С Успением Пресвятой Богородицы!", "Пусть этот день принесёт мир, свет и душевное спокойствие."], category: "Православный")
        }
        
        if day == 31 && month == 10 {
            return HolidayContent(images: ["holiday_halloween"], phrases: ["С Хеллоуином!", "Пусть этот вечер будет добрым и волшебным!"], category: "Католический")
        }
        
        if day == 6 && month == 1 {
            return HolidayContent(
                images: ["holiday_epithany"],
                phrases: [
                    "С праздником Богоявления!"
                ],
                category: "Католический"
            )
        }
        
        if (year == 2026 && day == 14 && month == 5) ||
            (year == 2027 && day == 6 && month == 5) ||
            (year == 2028 && day == 25 && month == 5) {
            
            return HolidayContent(
                images: ["holiday_Ascension"],
                phrases: [
                    "С Вознесением Господним!"
                ],
                category: "Католический"
            )
        }
        
        if (year == 2026 && day == 24 && month == 5) ||
            (year == 2027 && day == 16 && month == 5) ||
            (year == 2028 && day == 4 && month == 6) {
            
            return HolidayContent(
                images: ["holiday_trinity"],
                phrases: [
                    "С праздником Святой Троицы!"
                ],
                category: "Католический"
            )
        }
        
        if day == 1 && month == 11 {
            
            return HolidayContent(
                images: ["holiday_AllSaints"],
                phrases: [
                    "С Днем всех святых!"
                ],
                category: "Католический"
            )
        }
        
        if day == 8 && month == 12 {
            
            return HolidayContent(
                images: ["holiday_Conception"],
                phrases: [
                    "С праздником Непорочного зачатия Пресвятой Богородицы!"
                ],
                category: "Католический"
            )
        }
        
        if month == 11 && weekday == 5 && weekOfMonth == 4 {
            return HolidayContent(images: ["holiday_thanksgiving"], phrases: ["С Днём Благодарения!", "Пусть ваш дом будет наполнен семейным счастьем и благодарностью за каждый новый день."], category: "Католический")
        }
        
        if (day == 24 && month == 12) || (day == 25 && month == 12) {
            return HolidayContent(images: ["holiday_christmas", "holiday_christmas_2", "holiday_christmas_3"], phrases: ["С Рождеством!", "Пусть Рождество принесёт тепло и свет!"], category: "Католический")
        }
        
        // Еврейские праздники 2026–2028
        if (year == 2026 && day == 3 && month == 3) || (year == 2027 && day == 23 && month == 3) || (year == 2028 && day == 12 && month == 3) {
            return HolidayContent(images: ["holiday_purim"], phrases: ["С Пуримом! Пусть радость, свет и добро наполнят этот день!"], category: "Еврейский")
        }
        
        if (year == 2026 && month == 4 && day >= 2 && day <= 9) || (year == 2027 && month == 4 && day >= 22 && day <= 29) || (year == 2028 && month == 4 && day >= 11 && day <= 18) {
            return HolidayContent(images: ["holiday_Passover"], phrases: ["С Песахом! Пусть в доме будут свобода, мир и благословение!"], category: "Еврейский")
        }
        
        if (year == 2026 && day == 5 && month == 5) || (year == 2027 && day == 25 && month == 5) || (year == 2028 && day == 14 && month == 5) {
            return HolidayContent(images: ["holiday_lagbaomer"], phrases: ["С Лаг ба-Омером! Пусть в сердце горит добрый свет!"], category: "Еврейский")
        }
        
        if (year == 2026 && month == 9 && day >= 12 && day <= 13) || (year == 2027 && month == 10 && day >= 2 && day <= 3) || (year == 2028 && month == 9 && day >= 21 && day <= 22) {
            return HolidayContent(images: ["holiday_rosh"], phrases: ["С Рош ха-Шана! Сладкого, доброго и счастливого года!"], category: "Еврейский")
        }
        
        if (year == 2026 && day == 21 && month == 9) || (year == 2027 && day == 11 && month == 10) || (year == 2028 && day == 30 && month == 9) {
            return HolidayContent(images: ["holiday_yom_kippor"], phrases: ["С Йом-Кипуром. Пусть этот день принесёт очищение, мир и свет душе."], category: "Еврейский")
        }
        
        if (year == 2026 && ((month == 9 && day >= 26) || (month == 10 && day <= 2))) || (year == 2027 && month == 10 && day >= 16 && day <= 22) || (year == 2028 && month == 10 && day >= 5 && day <= 11) {
            return HolidayContent(images: ["holiday_sukkot"], phrases: ["С Суккотом! Пусть дом будет наполнен радостью и благословением!"], category: "Еврейский")
        }
        
        if (year == 2026 && month == 10 && day >= 3 && day <= 4) || (year == 2027 && month == 10 && day >= 23 && day <= 24) || (year == 2028 && month == 10 && day >= 12 && day <= 13) {
            return HolidayContent(images: ["holiday_simha_torah"], phrases: ["С Симхат-Тора! Пусть радость Торы освещает каждый день!"], category: "Еврейский")
        }
        
        // Симха Тора
        if (year == 2026 && day == 4 && month == 10) ||
            (year == 2027 && day == 24 && month == 10) ||
            (year == 2028 && day == 13 && month == 10) {
            return HolidayContent(
                images: ["holiday_Simha_Tora"],
                phrases: [
                    "С Симха Тора!"
                ],
                category: "Еврейский"
            )
        }
        
        // Тиша бе-Ав
        if (year == 2026 && day == 23 && month == 7) ||
            (year == 2027 && day == 12 && month == 8) ||
            (year == 2028 && day == 1 && month == 8) {
            return HolidayContent(
                images: ["holiday_TishaBAv"],
                phrases: [
                    "Пусть память о прошлом вдохновляет на надежду, мир и созидание."
                ],
                category: "Еврейский"
            )
        }
        
        if (year == 2026 && month == 12 && day >= 5 && day <= 12) || (year == 2027 && ((month == 12 && day >= 25) || (month == 1 && day == 1))) || (year == 2028 && month == 12 && day >= 13 && day <= 20) {
            return HolidayContent(images: ["holiday_hanuka"], phrases: ["С Ханукой! Пусть свет, тепло и чудо наполняют ваш дом!"], category: "Еврейский")
        }
        return nil
    }
    func shabbatStartDate(for date: Date = Date()) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        
        let weekday = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)
        
        // Пятница после 18:00
        if weekday == 6 && hour >= 18 {
            let startOfFriday = calendar.startOfDay(for: date)
            
            return calendar.date(
                byAdding: .hour,
                value: 18,
                to: startOfFriday
            )
        }
        
        // Суббота до 18:00
        if weekday == 7 && hour < 18 {
            guard let friday = calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            ) else {
                return nil
            }
            
            let startOfFriday = calendar.startOfDay(for: friday)
            
            return calendar.date(
                byAdding: .hour,
                value: 18,
                to: startOfFriday
            )
        }
        
        return nil
    }
    func openEmergencyWhatsAppMessages() {
        let contacts = loadEmergencyContacts()
        
        guard let firstContact = contacts.first else {
            showContacts = true
            return
        }
        
        openWhatsApp(
            for: firstContact,
            message: emergencyAlertText
        )
    }
    func loadEmergencyContacts() -> [EmergencyContact] {
        let contactsKey = "emergency_contacts"
        
        guard let data = UserDefaults.standard.data(
            forKey: contactsKey
        ) else {
            return []
        }
        
        return (
            try? JSONDecoder().decode(
                [EmergencyContact].self,
                from: data
            )
        ) ?? []
    }
    func openWhatsApp(
        for contact: EmergencyContact,
        message: String
    ) {
        let phone = contact.phoneDigits.filter(\.isNumber)
        
        guard !phone.isEmpty else {
            showMessageComposer = true
            return
        }
        
        guard let encodedMessage = message.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) else {
            showMessageComposer = true
            return
        }
        
        guard let url = URL(
            string: "whatsapp://send?phone=\(phone)&text=\(encodedMessage)"
        ) else {
            showMessageComposer = true
            return
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            showMessageComposer = true
            return
        }
        
        UIApplication.shared.open(
            url,
            options: [:]
        ) { success in
            if !success {
                showMessageComposer = true
            }
        }
    }
    
    func loadCheckIn() {
        if let savedDate = UserDefaults.standard.object(
            forKey: lastCheckInKey
        ) as? Date {
            lastCheckInDate = savedDate
            hasCheckedIn =
            Date().timeIntervalSince(savedDate) < 24 * 60 * 60
        } else {
            lastCheckInDate = nil
            hasCheckedIn = false
        }
    }
    
    private func markAsAlive() {
        let now = Date()
        
        // Сохраняем время последнего нажатия.
        lastCheckInDate = now
        
        UserDefaults.standard.set(
            now,
            forKey: lastCheckInKey
        )
        
        // Формируем JSON для будущей отправки на сервер.
        guard let jsonData = createBackendJSON(
            checkInDate: now
        ) else {
            return
        }
        
        // Пока сервера нет — сохраняем последний JSON локально.
        UserDefaults.standard.set(
            jsonData,
            forKey: "last_backend_payload"
        )
        
        // Печатаем JSON в консоли Xcode для проверки.
        if let jsonString = String(
            data: jsonData,
            encoding: .utf8
        ) {
            print("JSON для backend:")
            print(jsonString)
        }
        
        // Перезапускаем отсчёт 48 часов.
        Task {
            await CheckInNotificationManager.shared
                .schedule48HourCheckInNotification()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                print("Ошибка разрешения уведомлений: \(error.localizedDescription)")
            }
        }
    }
    
    
    func scheduleCheckInReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Мы волнуемся за вас!"
        content.body = "Пожалуйста, подтвердите, что с вами всё хорошо"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 36 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "check_in_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["check_in_reminder"])
        UNUserNotificationCenter.current().add(request)
    }
    
    func isHolidayAllowed(_ category: String) -> Bool {
        if category == "Нейтральный" { return true }
        if category == "Православный" { return showOrthodoxHolidays }
        if category == "Католический" { return showCatholicHolidays }
        if category == "Еврейский" || category == "Еврейский праздник" { return showJewishHolidays }
        return true
    }
    var emergencyAlertText: String {
        let savedName = UserDefaults.standard.string(
            forKey: "profile_display_name"
        )?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let userName: String
        
        if let savedName, !savedName.isEmpty {
            userName = savedName
        } else {
            userName = "Пользователь MorningHello"
        }
        
        return """
Внимание. \(userName) не подтвердил(а), что с ним или с ней всё хорошо, в течение последних 48 часов.

Пожалуйста, попробуйте связаться с ним или с ней напрямую.

Это автоматическое напоминание приложения MorningHello. Если существует непосредственная угроза жизни или здоровью, обратитесь в местные экстренные службы.
"""
    }
    var welcomeScreen: some View {
        return ZStack(alignment: .top) {
            VStack(spacing: 22) {
                
                Text(timeGreeting)
                    .font(
                        .system(
                            size: 36,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.brown)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Как ты сегодня?")
                    .font(.system(.title3, design: .rounded))
                    .foregroundColor(.brown)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if hasEmergencyContacts {
                    
                    Button {
                        if !isCheckInBlocked {
                            markAsAlive()
                        }
                        
                        showPostcard = true
                        
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "heart.fill")
                            
                            Text(
                                isCheckInBlocked
                                ? "Я в порядке"
                                : "Я живу"
                            )
                        }
                    }
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 16)
                    .background(
                        Color.orange.opacity(
                            isCheckInBlocked ? 0.45 : 0.75
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: .orange.opacity(0.35),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                    .opacity(isCheckInBlocked ? 0.65 : 1.0)
                    
                    Text(
                        "Если ты не нажмёшь кнопку в течение 48 часов — мы сообщим близким"
                    )
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.28))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: 330, alignment: .center)
                    .padding(.horizontal, 16)
                    
                } else {
                    
                    VStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                        
                        Text("Добавьте тревожный контакт")
                            .font(
                                .system(
                                    .title3,
                                    design: .rounded
                                )
                                .weight(.bold)
                            )
                            .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.28))                            .multilineTextAlignment(.center)
                        
                        Text(
                            "Без тревожного контакта приложение не сможет сообщить близким, если вы не отметитесь в течение 48 часов."
                        )
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.28))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .frame(maxWidth: 330)
                        .padding(.horizontal, 16)
                        
                        Button {
                            showContacts = true
                            
                        } label: {
                            Label(
                                "Добавить контакт",
                                systemImage: "person.badge.plus"
                            )
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded
                                )
                                .weight(.semibold)
                            )
                            .foregroundColor(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 14)
                            .background(Color.orange.opacity(0.75))
                            .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                Button {
                    showBirthdayGreeting = true

                } label: {
                    Label(
                        "Поздравить с днём рождения",
                        systemImage: "birthday.cake.fill"
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundColor(
                        Color(
                            red: 0.12,
                            green: 0.16,
                            blue: 0.28
                        )
                    )
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.55))
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                HStack(spacing: 14) {
                    Button {
                        showContacts = true
                        
                    } label: {
                        Label(
                            "Контакты",
                            systemImage: "person.2.fill"
                        )
                        .font(
                            .system(
                                .subheadline,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.28))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.55))
                        .clipShape(Capsule())
                    }
                    
                    Button {
                        showHolidaySettings = true
                        
                    } label: {
                        Label(
                            "Праздники",
                            systemImage: "calendar"
                        )
                        .font(
                            .system(
                                .subheadline,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.28))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.55))
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Button {
                    showProfile = true
                    
                } label: {
                    Label(
                        "Профиль",
                        systemImage: "person.crop.circle.fill"
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.28))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.55))
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .padding(.horizontal, 20)
            .safeAreaPadding(.top, 28)
        }
    }
    var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Доброе утро"
            
        case 12..<18:
            return "Добрый день"
            
        case 18..<22:
            return "Добрый вечер"
            
        default:
            return "Доброй ночи"
        }
    }
    private var currentPostcard: SelectedPostcard {

        // 1. День рождения
        if let birthday = birthdayContent(),
           let image = birthday.images.first,
           let phrase = birthday.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }

        // 2. Праздник
        if let holiday = holidayContent() {

            let availableCount = min(
                holiday.images.count,
                holiday.phrases.count
            )

            if availableCount > 0 {
                let index = stableDailyIndex(
                    count: availableCount,
                    salt: 500
                )

                return SelectedPostcard(
                    image: holiday.images[index],
                    phrase: holiday.phrases[index]
                )
            }
        }

        // 3. Понедельник
        if let monday = mondayCoffeeContent(),
           let image = monday.images.first,
           let phrase = monday.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }

        // 4. Шаббат
        if showJewishHolidays,
           let shabbat = currentShabbatContent() {

            return SelectedPostcard(
                image: shabbat.image,
                phrase: shabbat.phrase
            )
        }

        // 5. Воскресенье
        if showOrthodoxHolidays || showCatholicHolidays {
            if let sunday = sundayContent(),
               let image = sunday.images.first,
               let phrase = sunday.phrases.first {

                return SelectedPostcard(
                    image: image,
                    phrase: phrase
                )
            }
        }

        // 6. Февраль
        if let february = februaryContent(),
           let image = february.images.first,
           let phrase = february.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }

        // 7. Декабрь
        if let december = decemberContent(),
           let image = december.images.first,
           let phrase = december.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }
        // Ханука
        if let hanukkah = hanukkahContent(),
           let image = hanukkah.images.first,
           let phrase = hanukkah.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }
        // 8. Обычная сезонная открытка
        let weekday = currentWeekday()
        let seasonalImageName = "\(currentSeason())_\(weekday)"

        let fallbackImage = images.contains(seasonalImageName)
            ? seasonalImageName
            : "winter_monday"

        let fallbackPhrase: String

        if phrases.isEmpty {
            fallbackPhrase = "Доброе утро!"
        } else {
            let phraseIndex = stableDailyIndex(
                count: phrases.count,
                salt: 900
            )

            fallbackPhrase = phrases[phraseIndex]
        }

        return SelectedPostcard(
            image: fallbackImage,
            phrase: fallbackPhrase
        )
    }

    var smartImage: String {
        currentPostcard.image
    }

    var smartPhrase: String {
        currentPostcard.phrase
    }
    var postcardScreen: some View {
        PostcardScreen(
            imageName: smartImage,
            phrase: smartPhrase,
            profileDisplayName: profileDisplayName,
            onHomeTap: {
                showPostcard = false
            },
            onShareTap: {
                emergencyContactsForSharing =
                    loadContactsForSharing()

                guard !emergencyContactsForSharing.isEmpty
                else {
                    showContacts = true
                    return
                }

                showContactForWhatsApp = true
            }
        )
        .confirmationDialog(
            "Кому отправить открытку?",
            isPresented: $showContactForWhatsApp,
            titleVisibility: .visible
        ) {
            ForEach(loadContactsForSharing()) { contact in
                Button(
                    "WhatsApp: \(contact.name) \(contact.surname)"
                ) {
                    openWhatsApp(
                        for: contact,
                        message: postcardShareText
                    )
                }
            }

            Button("Поделиться с любым контактом") {
                showShareSheet = true
            }

            Button("Отправить всем через iMessage") {
                emergencyContactsForSharing =
                    loadContactsForSharing()

                showMessageComposer = true
            }

            Button("Отмена", role: .cancel) {
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let postcardImage = UIImage(
                named: smartImage
            ) {
                ShareSheet(
                    items: [
                        postcardImage,
                        postcardShareText
                    ]
                )
            } else {
                ShareSheet(
                    items: [
                        postcardShareText
                    ]
                )
            }
        }
        .sheet(isPresented: $showMessageComposer) {
            let contacts = loadContactsForSharing()

            MessageComposerView(
                recipients: contacts.map {
                    $0.phoneDigits
                },
                message: postcardShareText,
                image: UIImage(named: smartImage)
            )
        }
    }
        var body: some View {
            NavigationStack {
                ZStack {
                    
                    // Фон, обновляющийся каждую минуту
                    TimelineView(.everyMinute) { context in
                        Image(
                            AppBackground
                                .current(for: context.date)
                                .rawValue
                        )
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    }
                    
                    // Основное содержимое экрана
                    Group {
                        if showPostcard {
                            postcardScreen
                        } else {
                            welcomeScreen
                        }
                    }
                    .sheet(isPresented: $showContacts) {
                        EmergencyContactsView()
                    }
                    .sheet(
                        isPresented: $showBirthdayGreeting
                    ) {
                        BirthdayGreetingView(
                            emergencyContacts:
                                loadContactsForSharing()
                        )
                    }
                    .onChange(of: showContacts) { _, isShowing in
                        if !isShowing {
                            checkEmergencyContacts()
                        }
                    }
                    .sheet(isPresented: $showHolidaySettings) {
                        HolidaySettingsView()
                    }
                    .sheet(isPresented: $showProfile) {
                        ProfileView()
                    }
                    .onAppear {
                        showPostcard = false
                        loadCheckIn()
                        checkEmergencyContacts()
                        requestNotificationPermission()
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(
                            for: .openEmergencyMessage
                        )
                    ) { _ in
                        shouldOpenEmergencyMessage = true
                        showEmergencyMessageAlert = true
                    }
                    .alert(
                        "Прошло 48 часов",
                        isPresented: $showEmergencyMessageAlert
                    ) {
                        Button("Открыть WhatsApp") {
                            showEmergencyContactSelection = true
                        }
                        
                        Button("Открыть Сообщения") {
                            showMessageComposer = true
                        }
                        
                        Button("Отмена", role: .cancel) {
                        }
                    } message: {
                        Text(
                            """
                            Пользователь не подтвердил, что с ним всё хорошо, в течение последних 48 часов.
                            
                            Подготовить сообщение тревожным контактам?
                            """
                        )
                    }
                    .confirmationDialog(
                        "Кому открыть сообщение?",
                        isPresented: $showEmergencyContactSelection
                    ) {
                        ForEach(loadContactsForSharing()) { contact in
                            Button("\(contact.name) \(contact.surname)") {
                                openWhatsApp(
                                    for: contact,
                                    message: emergencyAlertText
                                )
                            }
                        }
                        
                        Button("Отмена", role: .cancel) {
                        }
                    }
                }
            }
        }
    }
