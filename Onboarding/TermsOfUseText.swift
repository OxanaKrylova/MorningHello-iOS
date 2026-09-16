//
//  TermsOfUseText.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/08/2026.
//
import Foundation

enum TermsOfUseText {

    static var text: String {
        AppLanguage.selected == .englishUS
            ? englishText
            : russianText
    }

    private static let russianText = """
Настоящие Условия использования регулируют доступ к мобильному приложению MorningHello для iPhone.

Пожалуйста, внимательно прочитайте настоящие Условия до начала использования Сервиса.Устанавливая Приложение, завершая онбординг или нажимая кнопку «Я прочитал(а)», вы подтверждаете, что прочитали, поняли и принимаете настоящие Условия MorningHello. Если вы не согласны с ними, не используйте Сервис.

1. Владелец Сервиса и контактные данные

Сервис предоставляет Оксана Крылова, индивидуальный предприниматель в Израиле.

Электронная почта: krylov.oxana@gmail.com

2. Назначение MorningHello

MorningHello помогает пользователю поддерживать регулярную связь с близкими людьми.

В Приложении пользователь может:
• отмечать своё состояние кнопкой «Я в порядке»;
• получать ежедневные открытки, праздничные открытки и открытки к дню рождения;
• редактировать текст пожелания перед отправкой;
• сохранять и отправлять открытки с собственными пожеланиями;
• указать от одного до двух тревожных контактов;
• использовать систему тревожных уведомлений.

3. MorningHello не является экстренной службой

MorningHello не является медицинской, охранной, спасательной, диспетчерской или иной экстренной службой и не осуществляет круглосуточное наблюдение за пользователем.

Отсутствие отметки «Я в порядке» не подтверждает, что пользователь находится в опасности.

При угрозе жизни, здоровью или безопасности необходимо немедленно обращаться в местные экстренные службы.

Нельзя полагаться на MorningHello как на единственный способ контроля безопасности или связи.

4. Возрастные ограничения

Самостоятельное использование MorningHello разрешено лицам, достигшим 16 лет.

Пользователь младше 16 лет может использовать Сервис только с предварительного согласия родителя или законного представителя и под его ответственностью.

5. Онбординг и профиль

Для начала полноценной работы Приложения пользователь проходит онбординг, заполняет профиль и добавляет не менее одного тревожного контакта.

6. Бесплатный период и подписка

Доступ к функциям MorningHello предоставляется по автоматически продлеваемой подписке через App Store.

Для отдельных тарифов App Store может предоставить бесплатный ознакомительный период. Его продолжительность, доступность для конкретного пользователя и право на повторное получение определяются Apple и отображаются перед подтверждением покупки.

После окончания бесплатного периода выбранная подписка автоматически становится платной, если пользователь не отменил её в настройках Apple до даты продления.

7. Тревожные контакты

Пользователь может добавить от одного до двух тревожных контактов.

Добавляя контакт, пользователь подтверждает, что вправе передать MorningHello его контактные данные для целей работы тревожных уведомлений.

8. Как работают тревожные оповещения

После нажатия «Я в порядке» на сервер передаётся временная отметка.

Если до окончания выбранного интервала сервер не получает новую отметку, MorningHello может попытаться отправить тревожное сообщение активным контактам.

Тревожное сообщение не является подтверждением чрезвычайной ситуации.

9. Технические ограничения

MorningHello не гарантирует доставку, своевременность или получение любого тревожного уведомления.

Пользователь обязан самостоятельно проверять актуальность контактов, работу подключения и иметь резервный способ связи.

10. Открытки

Открытки предоставляются для личного некоммерческого использования.

Пользователь может отправлять их через iMessage и другие совместимые приложения.

Использование открыток в коммерческих целях без письменного разрешения MorningHello запрещено.

11. Интеллектуальная собственность

Название MorningHello, логотип, дизайн, интерфейс, тексты, структура, программный код, подборки и открытки принадлежат MorningHello или используются на законном основании.

12. Персональные данные

Порядок обработки персональных данных описан в Политике конфиденциальности MorningHello.

Удаление приложения с iPhone само по себе может не удалить данные, ранее переданные на сервер.

13. Сторонние сервисы

Работа MorningHello может зависеть от Apple, App Store, iOS, Amazon Web Services, Amazon SES, операторов связи, почтовых сервисов и приложений обмена сообщениями.

14. Отказ от гарантий

В пределах, разрешённых законом, Сервис предоставляется «как есть» и «по мере доступности».

MorningHello не гарантирует непрерывную работу Сервиса и доставку каждого уведомления.

15. Ограничение ответственности

MorningHello не заменяет экстренные службы или резервные способы связи.

Пользователь несёт ответственность за точность введённых данных и актуальность тревожных контактов.

16. Применимое право

Настоящие Условия регулируются законодательством Государства Израиль с сохранением обязательных прав потребителя, применимых по месту его проживания.

17. Полная версия Условий использования

Полная и актуальная версия Условий использования MorningHello размещена на официальном сайте:

https://www.morninghelloapp.com/terms-and-conditions

Перед использованием приложения рекомендуется ознакомиться с полной версией документа.
"""

    private static let englishText = """
These Terms of Use govern access to the MorningHello mobile application for iPhone.

Please read these Terms carefully before using the Service. By installing the App, completing onboarding, or tapping “I Have Read and Agree,” you confirm that you have read, understood, and accepted these MorningHello Terms. If you do not agree, do not use the Service.

1. Service Owner and Contact Information

The Service is provided by Oxana Krylova, a sole proprietor registered in Israel.

Email: krylov.oxana@gmail.com

2. Purpose of MorningHello

MorningHello helps users stay in regular contact with people they care about.

In the App, a user can:
• check in by tapping “I’m OK”;
• receive daily, holiday, and birthday cards;
• edit a greeting before sending it;
• save and send cards with a personal message;
• add one or two emergency contacts;
• use the missed check-in notification system.

3. MorningHello Is Not an Emergency Service

MorningHello is not a medical, security, rescue, dispatch, or other emergency service, and it does not provide continuous monitoring.

A missed “I’m OK” check-in does not confirm that a user is in danger.

If there is a threat to life, health, or safety, contact local emergency services immediately.

Do not rely on MorningHello as the only way to monitor safety or stay in contact.

4. Age Requirements

MorningHello may be used independently by people age 16 or older.

A user under age 16 may use the Service only with the prior consent and under the responsibility of a parent or legal guardian.

5. Onboarding and Profile

To begin using all App features, the user completes onboarding, fills out a profile, and adds at least one emergency contact.

6. Free Trial and Subscription

Access to MorningHello features is provided through an auto-renewable App Store subscription.

For certain plans, the App Store may offer a free introductory period. Its duration, availability to a particular user, and eligibility for another offer are determined by Apple and shown before the purchase is confirmed.

After the free trial ends, the selected subscription automatically becomes paid unless the user cancels it in Apple settings before the renewal date.

7. Emergency Contacts

A user may add one or two emergency contacts.

By adding a contact, the user confirms that they are authorized to provide that person's contact details to MorningHello for missed check-in notifications.

8. How Missed Check-In Notifications Work

When the user taps “I’m OK,” a timestamp is sent to the server.

If the server does not receive another check-in before the selected interval ends, MorningHello may attempt to send a notification to active emergency contacts.

Such a notification does not confirm that an emergency has occurred.

9. Technical Limitations

MorningHello does not guarantee the delivery, timing, or receipt of any notification.

Users are responsible for keeping contact details current, checking their connection, and maintaining a backup method of communication.

10. Cards

Cards are provided for personal, noncommercial use.

Users may send them through iMessage and other compatible apps.

Commercial use of the cards without written permission from MorningHello is prohibited.

11. Intellectual Property

The MorningHello name, logo, design, interface, text, structure, software code, collections, and cards belong to MorningHello or are used lawfully.

12. Personal Data

The processing of personal data is described in the MorningHello Privacy Policy.

Deleting the App from an iPhone may not delete data previously transmitted to the server.

13. Third-Party Services

MorningHello may depend on Apple, the App Store, iOS, Amazon Web Services, Amazon SES, telecommunications providers, email services, and messaging apps.

14. Disclaimer of Warranties

To the extent permitted by law, the Service is provided “as is” and “as available.”

MorningHello does not guarantee uninterrupted operation or delivery of every notification.

15. Limitation of Liability

MorningHello does not replace emergency services or backup methods of communication.

Users are responsible for the accuracy of the information they enter and for keeping emergency contacts current.

16. Governing Law

These Terms are governed by the laws of the State of Israel, without limiting any mandatory consumer rights that apply where the user lives.

17. Full Terms of Use

The complete and current MorningHello Terms of Use are available on the official website:

https://www.morninghelloapp.com/terms-and-conditions

Please review the full document before using the App.
"""
}
