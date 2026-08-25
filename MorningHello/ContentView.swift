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
            // 05:00–10:59
            return .morning

        case 12..<18:
            // 11:00–16:59
            return .day

        case 18..<22:
            // 17:00–19:59
            return .sunset

        default:
            // 20:00–04:59
            return .night
        }
    }
}
struct ContentView: View {
    
    @State private var showContacts = false
    @State private var hasCheckedIn = false

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
    @State private var customMessage = ""
    @State private var showSubscription = false
    
    @State private var trialReminder: TrialReminderType?
    @State private var showTrialReminder = false
    
    @State private var showPostcardCatalog = false
    
    @AppStorage("showOrthodoxHolidays") private var showOrthodoxHolidays = true
    @AppStorage("showCatholicHolidays") private var showCatholicHolidays = true
    @AppStorage("showJewishHolidays") private var showJewishHolidays = true
    @AppStorage("app_instance_id")
    private var appInstanceId: String = UUID().uuidString
    @AppStorage("check_in_interval_hours")
    private var checkInIntervalHours: Int = 0
    
    private let lastCheckInKey = "lastCheckInDate"
    
    @AppStorage("profile_display_name")
    private var displayName = ""
    @State private var hasCheckedProfileOnLaunch = false
    // MARK: - Тест бесплатного периода

    @State private var isTrialActive = true

    @State private var trialEndDate: Date? =
        Calendar.current.date(
            byAdding: .day,
            value: 3,
            to: Date()
        )

    
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
    private var checkInIntervalText: String {
        checkInIntervalHours == 24
            ? "24 часа"
            : "\(checkInIntervalHours) часов"
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
    // MARK: - Формирование heartbeat
    
    private func createBackendPayload(
        checkInDate: Date
    ) -> HeartbeatRequest {
        
        let contacts = loadContactsForSharing()
        
        let backendContacts = contacts.map { contact in
            
            let firstName = contact.name
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            
            let lastName = contact.surname
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            
            let phone = contact.phoneDigits
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            
            let email = contact.email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            
            return HeartbeatEmergencyContact(
                firstName: firstName,
                lastName: lastName.isEmpty
                ? nil
                : lastName,
                phone: phone.isEmpty
                ? nil
                : phone,
                email: email
            )
        }
        
        return HeartbeatRequestBuilder.makeRequest(
            contacts: backendContacts,
            checkInDate: checkInDate,
            intervalHours: checkInIntervalHours
        )
    }
    
    private func getOrCreateAppInstanceID() -> UUID {
        let key = "app_instance_id"

        if let savedString = UserDefaults.standard.string(
            forKey: key
        ),
        let savedUUID = UUID(
            uuidString: savedString
        ) {
            return savedUUID
        }

        let newUUID = UUID()

        UserDefaults.standard.set(
            newUUID.uuidString,
            forKey: key
        )

        return newUUID
    }
    
    // MARK: - JSON для проверки в консоли
    
    private func createBackendJSON(
        checkInDate: Date
    ) -> Data? {
        
        let payload = createBackendPayload(
            checkInDate: checkInDate
        )
        
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .iso8601
        
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        
        do {
            return try encoder.encode(
                payload
            )
            
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
        smartPhrase
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
    
    func birthdayContent(
        for date: Date = Date()
    ) -> HolidayContent? {
        BirthdayPostcardProvider.content(
            for: date
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
    
    func holidayContent(
        for date: Date = Date()
    ) -> HolidayContent? {

        let today = date

        // 1. Православные подвижные праздники:
        // Страстная неделя, Пасха, посты и т. д.
        if showOrthodoxHolidays,
           let orthodoxContent =
            OrthodoxHolidayProvider.holyWeekContent(
                for: today
            ) {

            return orthodoxContent
        }

        // 2. Католические подвижные праздники:
        // Страстная неделя, Пасха и т. д.
        if showCatholicHolidays,
           let catholicHolyWeek =
            CatholicHolidayProvider.holyWeekContent(
                for: today
            ) {

            return catholicHolyWeek
        }
        
        // Католические дни Великого поста и Адвента.
        if showCatholicHolidays,
           let catholicSpecial =
            CatholicHolidayProvider.specialContent(
                for: today
            ) {

            return catholicSpecial
        }
        
        // 3. Прощёное воскресенье
        if showOrthodoxHolidays,
           let forgivenSunday =
            OrthodoxHolidayProvider.forgivenSundayContent(
                for: today
            ) {

            return forgivenSunday
        }

        // 4. Pancake Day
        // за 47 дней до католической Пасхи
        if showCatholicHolidays,
           let pancakeDay =
            CatholicHolidayProvider.pancakeDayContent(
                for: today
            ) {

            return pancakeDay
        }

        // 5. Нейтральные / международные праздники
        // показываются всегда
        if let internationalHoliday =
            InternationalHolidayProvider.content(
                for: today
            ) {

            return internationalHoliday
        }

        // Еврейские посты
        if showJewishHolidays,
           let jewishFast =
            JewishHolidayProvider.fastContent(
                for: today
            ) {

            return jewishFast
        }
        
        // 6. Еврейские праздники
        if showJewishHolidays,
           let jewishHoliday =
            JewishHolidayProvider.content(
                for: today
            ) {

            return jewishHoliday
        }

        // 7. Православные праздники
        // с фиксированными датами
        if showOrthodoxHolidays,
           let orthodoxHoliday =
            OrthodoxHolidayProvider.fixedContent(
                for: today
            ) {

            return orthodoxHoliday
        }

        // 8. Католические праздники
        // с фиксированными датами
        if showCatholicHolidays,
           let catholicHoliday =
            CatholicHolidayProvider.fixedContent(
                for: today
            ) {

            return catholicHoliday
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

        // Сохраняем отметку локально.
        lastCheckInDate = now

        UserDefaults.standard.set(
            now,
            forKey: lastCheckInKey
        )

        // Формируем запрос для сервера.
        let heartbeatRequest = makeHeartbeatRequest(
            checkInDate: now
        )

        // Перезапускаем локальный отсчёт 48 часов.
        Task {
            await CheckInNotificationManager.shared
                .scheduleCheckInNotification(
                    intervalHours: checkInIntervalHours
                )
        }

        // Отправляем JSON на сервер.
        Task {
            do {
                let appInstanceID =
                    getOrCreateAppInstanceID()

                try await HeartbeatAPIClient.shared
                    .sendHeartbeat(
                        appInstanceID: appInstanceID,
                        request: heartbeatRequest
                    )

                print("✅ Heartbeat успешно отправлен")
                print(
                    "App Instance ID:",
                    appInstanceID.uuidString
                )

            } catch {
                print("❌ Heartbeat не отправлен")
                print(
                    "Ошибка:",
                    error.localizedDescription
                )
            }
        }
    }
    private func makeHeartbeatRequest(
        checkInDate: Date
    ) -> HeartbeatRequest {

        let trimmedDisplayName =
            displayName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let contacts = loadContactsForSharing()

        let backendContacts = contacts.compactMap {
            HeartbeatEmergencyContact(
                from: $0
            )
        }

        return HeartbeatRequest(
            user: HeartbeatUser(
                name: trimmedDisplayName.isEmpty
                    ? nil
                    : trimmedDisplayName,
                gender: nil
            ),
            checkInIntervalHours: checkInIntervalHours,
            lastCheckIn: HeartbeatLastCheckIn(
                timestamp: checkInDate,
                timezone: TimeZone.current.identifier
            ),
            emergencyContacts: backendContacts
        )
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
Внимание. \(userName) не подтвердил(а), что с ним или с ней всё хорошо, в течение последних \(checkInIntervalText).
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
                        print(
                            "Нажата кнопка. isCheckInBlocked:",
                            isCheckInBlocked
                        )

                        markAsAlive()

                        customMessage = ""
                        showPostcard = true
                    }
                        
                   label: {
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
                        "Если ты не нажмёшь кнопку в течение \(checkInIntervalText) — мы сообщим близким"
                    )
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(
                        Color(
                            red: 0.55,
                            green: 0.30,
                            blue: 0.14
                        )
                    )
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
                            .foregroundColor(
                                Color(
                                    red: 0.55,
                                    green: 0.30,
                                    blue: 0.14
                                )
                            )
                            .multilineTextAlignment(.center)
                        Text(
                            "Без тревожного контакта приложение не сможет сообщить близким, если вы не отметитесь в течение \(checkInIntervalText)."
                        )
                        .font(
                            .system(
                                .footnote,
                                design: .rounded
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.55,
                                green: 0.30,
                                blue: 0.14
                            )
                        )
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
                    showPostcardCatalog = true
                    
                } label: {
                    Label(
                        "Коллекция открыток",
                        systemImage: "photo.on.rectangle.angled"
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


        // 2. Праздники
        //
        // holidayContent() должен учитывать:
        // - православные только при showOrthodoxHolidays
        // - католические только при showCatholicHolidays
        // - еврейские только при showJewishHolidays
        // - нейтральные всегда

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


        // 3. Ханука
        //
        // Если Ханука пока не входит в holidayContent(),
        // проверяем её здесь, ДО понедельника
        // и ДО месячных открыток.

        if showJewishHolidays,
           let hanukkah = hanukkahContent(),
           let image = hanukkah.images.first,
           let phrase = hanukkah.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }


        // 4. Понедельник

        if let monday = mondayCoffeeContent(),
           let image = monday.images.first,
           let phrase = monday.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }


        // 5. Шаббат

        if showJewishHolidays,
           let shabbat = currentShabbatContent() {

            return SelectedPostcard(
                image: shabbat.image,
                phrase: shabbat.phrase
            )
        }


        // 6. Воскресенье

        if !showJewishHolidays ||
           showOrthodoxHolidays ||
           showCatholicHolidays {

            if let sunday = sundayContent(),
               let image = sunday.images.first,
               let phrase = sunday.phrases.first {

                return SelectedPostcard(
                    image: image,
                    phrase: phrase
                )
            }
        }


        // 7. Февраль

        if let february = februaryContent(),
           let image = february.images.first,
           let phrase = february.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }


        // 8. Декабрь

        if let december = decemberContent(),
           let image = december.images.first,
           let phrase = december.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }


        // Август — обычные дни месяца

        if let augustIndex =
            augustOrdinaryDayIndex(
                for: Date()
            ),
           let august =
            AugustPostcardProvider.content(
                index: augustIndex
            ),
           let image = august.images.first,
           let phrase = august.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }


        // 10. Сентябрь

        if let september =
            SeptemberPostcardProvider.content(
                for: Date()
            ),
           let image = september.images.first,
           let phrase = september.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }

        // 11. Октябрь

        if let october =
            OctoberPostcardProvider.content(
                for: Date()
            ),
           let image = october.images.first,
           let phrase = october.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }

        // 12. Ноябрь

        if let november =
            NovemberPostcardProvider.content(
                for: Date()
            ),
           let image = november.images.first,
           let phrase = november.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }

        // Январь — обычные дни месяца

        if let januaryIndex =
            ordinaryDayIndex(
                for: Date(),
                month: 1
            ),
           let january =
            JanuaryPostcardProvider.content(
                index: januaryIndex
            ),
           let image = january.images.first,
           let phrase = january.phrases.first {

            return SelectedPostcard(
                image: image,
                phrase: phrase
            )
        }
        
        // 13. Обычная сезонная открытка

        let weekday = currentWeekday()

        let seasonalImageName =
            "\(currentSeason())_\(weekday)"

        let fallbackImage =
            images.contains(
                seasonalImageName
            )
            ? seasonalImageName
            : "winter_monday"

        let fallbackPhrase: String

        if phrases.isEmpty {

            fallbackPhrase =
                "Доброе утро!"

        } else {

            let phraseIndex =
                stableDailyIndex(
                    count: phrases.count,
                    salt: 900
                )

            fallbackPhrase =
                phrases[phraseIndex]
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
            customMessage: $customMessage,
            onHomeTap: {
                showPostcard = false
            },
            onShareTap: {
                emergencyContactsForSharing =
                loadContactsForSharing()
                
                guard !emergencyContactsForSharing.isEmpty else {
                    showContacts = true
                    return
                }
                
                showContactForWhatsApp = true
            }
        )
        .confirmationDialog(
            "Как отправить открытку?",
            isPresented: $showContactForWhatsApp,
            titleVisibility: .visible
        ) {
            ForEach(loadContactsForSharing()) { contact in
                Button(
                    "iMessage: \(contact.name) \(contact.surname)"
                ) {
                    emergencyContactsForSharing = [contact]
                    showContactForWhatsApp = false

                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 0.6
                    ) {
                        showMessageComposer = true
                    }
                }
            }

            Button("Выбрать мессенджер") {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.5
                ) {
                    preparePostcardForSharing(
                        imageName: smartImage,
                        phrase: smartPhrase
                    )
                }
            }

            Button("Отмена", role: .cancel) {
            }
        }

        .sheet(isPresented: $showMessageComposer) {
            let contacts = emergencyContactsForSharing
            
            let renderer = PostcardRenderer()
            
            let finalImage = renderer.render(
                input: PostcardRenderInput(
                    imageName: smartImage,
                    baseText: smartPhrase,
                    customText: customMessage
                )
            )
            
            MessageComposerView(
                recipients: contacts.map {
                    $0.phoneDigits
                },
                message: "",
                image: finalImage
            )
        }
    }
    var body: some View {
        NavigationStack {
            ZStack {

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
                    isPresented:
                        $showPostcardCatalog
                ) {

                    PostcardCatalogView()
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
                .onAppear {
                    openProfileIfNeeded()
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
                    "Прошло \(checkInIntervalText)",
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
                        Пользователь не подтвердил, что с ним всё хорошо, в течение последних \(checkInIntervalText).
                        """
                    )
                }
                .alert(
                    trialReminder?.title ?? "",
                    isPresented: $showTrialReminder
                ) {

                    Button("Понятно") {

                        if let reminder = trialReminder,
                           let trialEndDate = trialEndDate {

                            TrialReminderManager.shared
                                .markAsShown(
                                    type: reminder,
                                    trialEndDate: trialEndDate
                                )
                        }

                        trialReminder = nil
                    }

                } message: {

                    Text(
                        trialReminder?.message ?? ""
                    )
                }
                .confirmationDialog(
                    "Кому открыть сообщение?",
                    isPresented: $showEmergencyContactSelection
                ) {
                    ForEach(
                        loadContactsForSharing()
                    ) { contact in
                        Button(
                            "\(contact.name) \(contact.surname)"
                        ) {
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
    private func augustOrdinaryDayIndex(
        for date: Date
    ) -> Int? {

        let calendar = Calendar.current

        guard calendar.component(
            .month,
            from: date
        ) == 8 else {
            return nil
        }

        let year = calendar.component(
            .year,
            from: date
        )

        guard let augustStart =
            calendar.date(
                from: DateComponents(
                    year: year,
                    month: 8,
                    day: 1
                )
            )
        else {
            return nil
        }

        let today =
            calendar.startOfDay(for: date)

        var current =
            calendar.startOfDay(
                for: augustStart
            )

        var ordinaryIndex = 0

        while current <= today {

            if !isPriorityPostcardDay(
                current
            ) {

                if calendar.isDate(
                    current,
                    inSameDayAs: today
                ) {
                    return ordinaryIndex
                }

                ordinaryIndex += 1
            }

            guard let nextDay =
                calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: current
                )
            else {
                break
            }

            current = nextDay
        }

        return nil
    }
    
    private func isPriorityPostcardDay(
        _ date: Date
    ) -> Bool {

        let calendar = Calendar.current

        // Праздник
        if holidayContent(
            for: date
        ) != nil {
            return true
        }

        let weekday =
            calendar.component(
                .weekday,
                from: date
            )

        // Понедельник
        if weekday == 2 {
            return true
        }

        // Суббота / Шаббат
        if showJewishHolidays,
           weekday == 7 {
            return true
        }
        // Воскресенье
        if (
            !showJewishHolidays ||
            showOrthodoxHolidays ||
            showCatholicHolidays
        ),
           weekday == 1 {

            return true
        }

        return false
    }
    private func openProfileIfNeeded() {
        guard !hasCheckedProfileOnLaunch else {
            return
        }

        hasCheckedProfileOnLaunch = true

        let trimmedName = displayName.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )

        if trimmedName.isEmpty {
            showProfile = true
        }
    }
    
    @MainActor
    private func preparePostcardForSharing(
        imageName: String,
        phrase: String
    ) {
        let renderer = PostcardRenderer()

        guard let finalImage = renderer.render(
            input: PostcardRenderInput(
                imageName: imageName,
                baseText: phrase,
                customText: customMessage
            )
        ) else {
            print(
                "Не удалось создать открытку: \(imageName)"
            )
            return
        }

        presentActivityViewController(
            items: [
                finalImage
            ]
        )
    }
    @MainActor
    private func presentActivityViewController(
        items: [Any]
    ) {
        guard !items.isEmpty else {
            return
        }

        guard let windowScene =
            UIApplication.shared.connectedScenes
                .compactMap({
                    $0 as? UIWindowScene
                })
                .first(where: {
                    $0.activationState == .foregroundActive
                })
        else {
            print("Не удалось найти активную сцену")
            return
        }

        guard let window =
            windowScene.windows.first(where: {
                $0.isKeyWindow
            })
        else {
            print("Не удалось найти активное окно")
            return
        }

        guard let presenter =
            topViewController(
                from: window.rootViewController
            )
        else {
            print("Не удалось найти контроллер")
            return
        }

        let activityController =
            UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )

        if let popover =
            activityController.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 1,
                height: 1
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(
            activityController,
            animated: true
        )
    }
    private func topViewController(
        from controller: UIViewController?
    ) -> UIViewController? {
        if let presented =
            controller?.presentedViewController {
            return topViewController(
                from: presented
            )
        }

        if let navigation =
            controller as? UINavigationController {
            return topViewController(
                from: navigation.visibleViewController
            )
        }

        if let tabBar =
            controller as? UITabBarController {
            return topViewController(
                from: tabBar.selectedViewController
            )
        }

        return controller
    }
    private func ordinaryDayIndex(
        for date: Date,
        month targetMonth: Int
    ) -> Int? {

        let calendar = Calendar.current

        guard calendar.component(
            .month,
            from: date
        ) == targetMonth else {
            return nil
        }

        let year = calendar.component(
            .year,
            from: date
        )

        guard let monthStart =
            calendar.date(
                from: DateComponents(
                    year: year,
                    month: targetMonth,
                    day: 1
                )
            )
        else {
            return nil
        }

        let today =
            calendar.startOfDay(
                for: date
            )

        var current =
            calendar.startOfDay(
                for: monthStart
            )

        var ordinaryIndex = 0

        while current <= today {

            if !isPriorityPostcardDay(
                current
            ) {

                if calendar.isDate(
                    current,
                    inSameDayAs: today
                ) {
                    return ordinaryIndex
                }

                ordinaryIndex += 1
            }

            guard let nextDay =
                calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: current
                )
            else {
                break
            }

            current = nextDay
        }

        return nil
    }
    private func checkTrialReminder() {

        guard isTrialActive,
              let trialEndDate = trialEndDate
        else {
            return
        }

        guard let reminder =
            TrialReminderManager.shared
                .reminderToShow(
                    trialEndDate: trialEndDate
                )
        else {
            return
        }

        trialReminder = reminder
        showTrialReminder = true
    }
}
