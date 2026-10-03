//
//  TermsOfUseText.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/08/2026.
//

import Foundation

enum TermsOfUseText {

    static var text: String {
        switch AppLanguage.selected {
        case .russian:
            return russianText

        case .englishUS:
            return englishText

        case .spanishLatinAmerica:
            return spanishText
        }
    }

    // MARK: - Russian

    private static let russianText = """
Настоящие Условия использования регулируют доступ к мобильному приложению MorningHello для iPhone.

Пожалуйста, внимательно прочитайте настоящие Условия до начала использования Сервиса. Устанавливая Приложение, завершая онбординг или нажимая кнопку «Я прочитал(а)», вы подтверждаете, что прочитали, поняли и принимаете настоящие Условия MorningHello. Если вы не согласны с ними, не используйте Сервис.

1. Владелец Сервиса и контактные данные

Сервис предоставляет Оксана Крылова, индивидуальный предприниматель в Израиле.

Электронная почта: krylov.oxana@gmail.com

2. Назначение MorningHello

MorningHello помогает пользователю поддерживать регулярную связь с близкими людьми.

В Приложении пользователь может:
• отмечать своё состояние кнопкой «Я в порядке»;
• получать ежедневные открытки, праздничные открытки и открытки ко дню рождения;
• редактировать текст пожелания перед отправкой;
• сохранять и отправлять открытки с собственными пожеланиями;
• указать от одного до двух тревожных контактов;
• использовать систему тревожных уведомлений;
• по желанию сохранять сведения максимум о двух питомцах;
• добавлять напоминания для поддержания общения с близкими людьми.

3. MorningHello не является экстренной службой

MorningHello не является медицинской, охранной, спасательной, диспетчерской или иной экстренной службой и не осуществляет круглосуточное наблюдение за пользователем.

Отсутствие отметки «Я в порядке» не подтверждает, что пользователь находится в опасности.

При угрозе жизни, здоровью или безопасности необходимо немедленно обращаться в местные экстренные службы.

Нельзя полагаться на MorningHello как на единственный способ контроля безопасности или связи.

Информация о местных экстренных службах, которая может отображаться с учётом выбранной страны проживания, носит справочный характер. Пользователь должен самостоятельно проверять актуальность номеров и порядок обращения в экстренные службы в своей стране.

4. Возрастные ограничения

Самостоятельное использование MorningHello разрешено лицам, достигшим 16 лет.

Пользователь младше 16 лет может использовать Сервис только с предварительного согласия родителя или законного представителя и под его ответственностью.

5. Онбординг и профиль

Для начала полноценной работы Приложения пользователь проходит онбординг, заполняет обязательные поля профиля и добавляет не менее одного тревожного контакта.

Профиль пользователя может включать имя, форму обращения, день и месяц рождения, номер телефона, страну проживания, выбранный интервал между отметками и другие настройки, необходимые для работы Сервиса.

Номер телефона может использоваться для отправки кодов и важных сервисных сообщений, связанных с подпиской, восстановлением доступа, настройкой и работой MorningHello. Номер телефона не используется для рекламных сообщений без отдельного согласия пользователя.

Страна проживания используется для региональных настроек Сервиса, выбора подходящего формата связи и отображения справочной информации о местных экстренных службах. MorningHello не связывается с экстренными службами автоматически.

Пользователь несёт ответственность за точность номера телефона, страны проживания и других данных профиля.

6. Бесплатный период и подписка

Доступ к функциям MorningHello предоставляется по автоматически продлеваемой подписке через App Store.

Для отдельных тарифов App Store может предоставить бесплатный ознакомительный период. Его продолжительность, доступность для конкретного пользователя и право на повторное получение определяются Apple и отображаются перед подтверждением покупки.

После окончания бесплатного периода выбранная подписка автоматически становится платной, если пользователь не отменил её в настройках Apple до даты продления.

Удаление Приложения с iPhone не отменяет действующую подписку. Управление подпиской и её отмена выполняются через настройки Apple Account.

7. Тревожные контакты

Пользователь может добавить от одного до двух тревожных контактов.

Добавляя контакт, пользователь подтверждает, что вправе передать MorningHello его контактные данные для целей работы тревожных уведомлений.

Тревожные сообщения могут отправляться только контактам, которые подтвердили своё согласие и имеют активный статус в системе MorningHello.

8. Как работают тревожные оповещения

После нажатия «Я в порядке» на сервер передаётся временная отметка.

Если до окончания выбранного интервала сервер не получает новую отметку, MorningHello может попытаться отправить тревожное сообщение подтверждённым активным контактам.

Тревожное сообщение не является подтверждением чрезвычайной ситуации.

Изменение профиля, данных питомца, тревожных контактов, подписки, эмоционального состояния или напоминаний не считается отметкой «Я в порядке» и не продлевает интервал мониторинга.

9. Данные о питомцах

Пользователь может по желанию сохранить сведения максимум о двух питомцах.

Сведения о питомце могут включать:
• имя;
• вид животного;
• информацию о месте нахождения;
• инструкции по кормлению;
• фотографию упаковки корма;
• информацию о лекарствах;
• сведения об аллергиях и важных особенностях здоровья;
• особенности поведения;
• название и телефон ветеринарной клиники;
• место хранения поводка, переноски и других необходимых вещей;
• дополнительные инструкции по уходу.

Заполнение формы питомца является добровольным. Пользователь самостоятельно определяет объём предоставляемой информации.

Данные о питомце и фотография корма могут передаваться и храниться на сервере MorningHello. При пропущенной отметке они могут быть предоставлены только подтверждённым тревожным контактам, чтобы помочь им организовать помощь питомцу.

Данные питомца не передаются покупателю спонсорской подписки только на основании того, что он оплатил доступ. Покупатель может получить такие сведения только в том случае, если он отдельно добавлен и подтверждён в качестве тревожного контакта.

Пользователь подтверждает, что имеет право предоставлять загружаемые сведения и фотографию. Не следует размещать на фотографии документы, банковские данные, пароли, коды доступа или другую информацию, не относящуюся к уходу за питомцем.

MorningHello не является ветеринарной службой и не проверяет правильность инструкций по кормлению, лечению или уходу за питомцем.

10. Технические ограничения

MorningHello не гарантирует доставку, своевременность или получение любого тревожного уведомления.

Пользователь обязан самостоятельно проверять актуальность контактов, работу подключения и иметь резервный способ связи.

Доступность сервера, интернета, App Store, операторов связи, почтовых сервисов и приложений обмена сообщениями может влиять на работу отдельных функций MorningHello.

11. Открытки и напоминания

Открытки предоставляются для личного некоммерческого использования.

Пользователь может отправлять их через iMessage и другие совместимые приложения.

Использование открыток в коммерческих целях без письменного разрешения MorningHello запрещено.

Напоминания об общении хранятся локально на устройстве пользователя, не являются тревожными уведомлениями, не передаются тревожным контактам и не влияют на срок следующей отметки «Я в порядке».

12. Интеллектуальная собственность

Название MorningHello, логотип, дизайн, интерфейс, тексты, структура, программный код, подборки и открытки принадлежат MorningHello или используются на законном основании.

13. Персональные данные

Порядок обработки персональных данных описан в Политике конфиденциальности MorningHello.

В зависимости от используемых функций MorningHello может обрабатывать данные профиля, номер телефона, страну проживания, данные подписки, сведения о тревожных контактах, данные мониторинга, сведения о питомцах и фотографию упаковки корма.

Данные используются только для предоставления функций MorningHello, управления подпиской и доступом, работы серверного мониторинга, отправки сервисных и тревожных сообщений, применения региональных настроек и помощи питомцу в случае пропущенной отметки.

Эмоциональные отметки и напоминания об общении хранятся локально на устройстве и не передаются на Backend, если иное прямо не указано пользователю до начала такой передачи.

Удаление Приложения с iPhone само по себе может не удалить данные, ранее переданные на сервер.

Для запроса на доступ, исправление или удаление данных пользователь может обратиться по адресу:

krylov.oxana@gmail.com

Удаление данных может быть ограничено обязанностями по хранению сведений о подписках, платежах, безопасности и соблюдению законодательства.

14. Сторонние сервисы

Работа MorningHello может зависеть от Apple, App Store, iOS, Amazon Web Services, Amazon SES, операторов связи, почтовых сервисов и приложений обмена сообщениями.

Использование таких сервисов может также регулироваться их собственными условиями использования и политиками конфиденциальности.

15. Отказ от гарантий

В пределах, разрешённых законом, Сервис предоставляется «как есть» и «по мере доступности».

MorningHello не гарантирует непрерывную работу Сервиса, доставку каждого уведомления или возможность немедленно связаться с тревожным контактом.

16. Ограничение ответственности

MorningHello не заменяет экстренные службы, медицинскую, ветеринарную или социальную помощь, а также резервные способы связи.

Пользователь несёт ответственность за точность введённых данных, актуальность тревожных контактов, номера телефона, страны проживания и инструкций по уходу за питомцем.

17. Применимое право

Настоящие Условия регулируются законодательством Государства Израиль с сохранением обязательных прав потребителя, применимых по месту его проживания.

18. Полная версия Условий использования

Полная и актуальная версия Условий использования MorningHello размещена на официальном сайте:

https://www.morninghelloapp.com/ru/terms-and-conditions

Перед использованием Приложения рекомендуется ознакомиться с полной версией документа.
"""

    // MARK: - English

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
• use the missed check-in notification system;
• optionally save information for up to two pets;
• create reminders for staying in touch with people they care about.

3. MorningHello Is Not an Emergency Service

MorningHello is not a medical, security, rescue, dispatch, or other emergency service, and it does not provide continuous monitoring.

A missed “I’m OK” check-in does not confirm that a user is in danger.

If there is a threat to life, health, or safety, contact local emergency services immediately.

Do not rely on MorningHello as the only way to monitor safety or stay in contact.

Information about local emergency services that may be displayed based on the selected country of residence is provided for general reference only. Users must independently verify the current telephone numbers and procedures for contacting emergency services in their country.

4. Age Requirements

MorningHello may be used independently by people age 16 or older.

A user under age 16 may use the Service only with the prior consent and under the responsibility of a parent or legal guardian.

5. Onboarding and Profile

To begin using all App features, the user completes onboarding, fills out the required profile fields, and adds at least one emergency contact.

The user profile may include the user’s name, form of address, day and month of birth, telephone number, country of residence, selected check-in interval, and other settings required for the operation of the Service.

The telephone number may be used to send codes and important service messages related to subscriptions, access recovery, setup, and the operation of MorningHello. The telephone number is not used for advertising messages without the user’s separate consent.

The country of residence is used for regional Service settings, selecting an appropriate communication format, and displaying general information about local emergency services. MorningHello does not automatically contact emergency services.

The user is responsible for the accuracy of their telephone number, country of residence, and other profile information.

6. Free Trial and Subscription

Access to MorningHello features is provided through an auto-renewable App Store subscription.

For certain plans, the App Store may offer a free introductory period. Its duration, availability to a particular user, and eligibility for another offer are determined by Apple and shown before the purchase is confirmed.

After the free trial ends, the selected subscription automatically becomes paid unless the user cancels it in Apple settings before the renewal date.

Deleting the App from an iPhone does not cancel an active subscription. Subscription management and cancellation are handled through the user’s Apple Account settings.

7. Emergency Contacts

A user may add one or two emergency contacts.

By adding a contact, the user confirms that they are authorized to provide that person’s contact details to MorningHello for missed check-in notifications.

Emergency notifications may be sent only to contacts who have confirmed their consent and have an active status in the MorningHello system.

8. How Missed Check-In Notifications Work

When the user taps “I’m OK,” a timestamp is sent to the server.

If the server does not receive another check-in before the selected interval ends, MorningHello may attempt to send a notification to confirmed active emergency contacts.

Such a notification does not confirm that an emergency has occurred.

Changes to the profile, pet information, emergency contacts, subscription, emotional state, or reminders do not count as an “I’m OK” check-in and do not extend the monitoring interval.

9. Pet Information

A user may optionally save information for up to two pets.

Pet information may include:
• the pet’s name;
• the type of animal;
• information about where the pet is located;
• feeding instructions;
• a photograph of the food packaging;
• medication information;
• allergies and important health information;
• behavioral information;
• the veterinary clinic’s name and telephone number;
• the location of the leash, carrier, and other necessary items;
• additional care instructions.

Completing the pet form is voluntary. The user determines the amount of information they provide.

Pet information and the food photograph may be transmitted to and stored on MorningHello servers. Following a missed check-in, this information may be provided only to confirmed emergency contacts to help them arrange assistance for the pet.

Pet information is not disclosed to the purchaser of a sponsored subscription solely because that person paid for access. A purchaser may receive this information only if they have been separately added and confirmed as an emergency contact.

The user confirms that they are authorized to provide the uploaded information and photograph. The photograph should not contain identity documents, banking information, passwords, access codes, or other information unrelated to the pet’s care.

MorningHello is not a veterinary service and does not verify the accuracy of feeding, medication, or pet-care instructions.

10. Technical Limitations

MorningHello does not guarantee the delivery, timing, or receipt of any emergency notification.

Users are responsible for keeping contact details current, checking their connection, and maintaining a backup method of communication.

The availability of servers, internet access, the App Store, telecommunications providers, email services, and messaging applications may affect the operation of certain MorningHello features.

11. Cards and Reminders

Cards are provided for personal, noncommercial use.

Users may send them through iMessage and other compatible applications.

Commercial use of the cards without written permission from MorningHello is prohibited.

Communication reminders are stored locally on the user’s device, are not emergency notifications, are not disclosed to emergency contacts, and do not affect the deadline for the next “I’m OK” check-in.

12. Intellectual Property

The MorningHello name, logo, design, interface, text, structure, software code, collections, and cards belong to MorningHello or are used lawfully.

13. Personal Data

The processing of personal data is described in the MorningHello Privacy Policy.

Depending on the features used, MorningHello may process profile information, a telephone number, country of residence, subscription information, emergency-contact information, monitoring data, pet information, and a photograph of pet food packaging.

The information is used only to provide MorningHello features, manage subscriptions and access, operate server-based monitoring, send service and emergency messages, apply regional settings, and assist a pet following a missed check-in.

Emotional check-ins and communication reminders are stored locally on the device and are not transmitted to the Backend unless the user is expressly informed otherwise before such transmission begins.

Deleting the App from an iPhone may not delete information previously transmitted to the server.

To request access to, correction of, or deletion of personal information, the user may contact:

krylov.oxana@gmail.com

Deletion may be limited by legal obligations concerning subscription, payment, security, and compliance records.

14. Third-Party Services

MorningHello may depend on Apple, the App Store, iOS, Amazon Web Services, Amazon SES, telecommunications providers, email services, and messaging applications.

The use of such services may also be governed by their own terms of use and privacy policies.

15. Disclaimer of Warranties

To the extent permitted by law, the Service is provided “as is” and “as available.”

MorningHello does not guarantee uninterrupted operation, delivery of every notification, or the immediate availability of an emergency contact.

16. Limitation of Liability

MorningHello does not replace emergency services, medical, veterinary, or social assistance, or backup methods of communication.

Users are responsible for the accuracy of the information they enter and for keeping emergency contacts, telephone numbers, country of residence, and pet-care instructions current.

17. Governing Law

These Terms are governed by the laws of the State of Israel, without limiting any mandatory consumer rights that apply where the user lives.

18. Full Terms of Use

The complete and current MorningHello Terms of Use are available on the official website:

https://www.morninghelloapp.com/terms-and-conditions

Please review the full document before using the App.
"""

    // MARK: - Spanish

    private static let spanishText = """
Estas Condiciones de Uso regulan el acceso a la aplicación móvil MorningHello para iPhone.

Lee atentamente estas Condiciones antes de utilizar el Servicio. Al instalar la Aplicación, completar el proceso de incorporación o pulsar «He leído y acepto», confirmas que has leído, comprendido y aceptado estas Condiciones de MorningHello. Si no estás de acuerdo, no utilices el Servicio.

1. Titular del Servicio e información de contacto

El Servicio es proporcionado por Oxana Krylova, trabajadora autónoma registrada en Israel.

Correo electrónico: krylov.oxana@gmail.com

2. Finalidad de MorningHello

MorningHello ayuda a las personas usuarias a mantener un contacto regular con sus seres queridos.

En la Aplicación, la persona usuaria puede:
• confirmar que se encuentra bien pulsando «Estoy bien»;
• recibir postales diarias, festivas y de cumpleaños;
• editar el texto de una felicitación antes de enviarla;
• guardar y enviar postales con un mensaje personal;
• añadir uno o dos contactos de emergencia;
• utilizar el sistema de avisos por ausencia de confirmación;
• guardar voluntariamente información de hasta dos mascotas;
• crear recordatorios para mantener el contacto con sus seres queridos.

3. MorningHello no es un servicio de emergencia

MorningHello no es un servicio médico, de seguridad, rescate, despacho ni otro tipo de servicio de emergencia, y no realiza una vigilancia continua de la persona usuaria.

La ausencia de una confirmación «Estoy bien» no demuestra que la persona usuaria se encuentre en peligro.

Si existe una amenaza para la vida, la salud o la seguridad, deben contactarse inmediatamente los servicios de emergencia locales.

No se debe confiar en MorningHello como único medio para controlar la seguridad o mantener el contacto.

La información sobre servicios de emergencia locales que pueda mostrarse según el país de residencia seleccionado se proporciona únicamente como referencia general. La persona usuaria debe verificar por su cuenta los números y procedimientos vigentes para contactar a los servicios de emergencia de su país.

4. Requisitos de edad

MorningHello puede ser utilizado de forma independiente por personas de 16 años o más.

Una persona menor de 16 años solo puede utilizar el Servicio con el consentimiento previo y bajo la responsabilidad de su madre, padre o representante legal.

5. Incorporación y perfil

Para comenzar a utilizar todas las funciones de la Aplicación, la persona usuaria completa el proceso de incorporación, rellena los campos obligatorios del perfil y añade al menos un contacto de emergencia.

El perfil puede incluir el nombre, la forma de tratamiento, el día y mes de nacimiento, el número de teléfono, el país de residencia, el intervalo seleccionado entre confirmaciones y otros ajustes necesarios para el funcionamiento del Servicio.

El número de teléfono puede utilizarse para enviar códigos y mensajes importantes del Servicio relacionados con la suscripción, la recuperación del acceso, la configuración y el funcionamiento de MorningHello. El número de teléfono no se utiliza para mensajes publicitarios sin el consentimiento independiente de la persona usuaria.

El país de residencia se utiliza para los ajustes regionales del Servicio, la selección de un formato de comunicación adecuado y la presentación de información general sobre los servicios de emergencia locales. MorningHello no contacta automáticamente a los servicios de emergencia.

La persona usuaria es responsable de la exactitud de su número de teléfono, país de residencia y demás información del perfil.

6. Período gratuito y suscripción

El acceso a las funciones de MorningHello se proporciona mediante una suscripción de renovación automática a través de App Store.

Para determinados planes, App Store puede ofrecer un período introductorio gratuito. Apple determina su duración, disponibilidad para cada persona y posibilidad de volver a utilizar una oferta introductoria. Las condiciones se muestran antes de confirmar la compra.

Al finalizar el período gratuito, la suscripción seleccionada pasa automáticamente a ser de pago, salvo que la persona usuaria la cancele en los ajustes de Apple antes de la fecha de renovación.

Eliminar la Aplicación del iPhone no cancela una suscripción activa. La gestión y cancelación de la suscripción se realizan desde los ajustes de la cuenta de Apple.

7. Contactos de emergencia

La persona usuaria puede añadir uno o dos contactos de emergencia.

Al añadir un contacto, la persona usuaria confirma que está autorizada para proporcionar sus datos de contacto a MorningHello con el fin de enviar avisos por ausencia de confirmación.

Los avisos de emergencia solo pueden enviarse a contactos que hayan confirmado su consentimiento y tengan un estado activo en el sistema MorningHello.

8. Funcionamiento de los avisos por ausencia de confirmación

Cuando la persona usuaria pulsa «Estoy bien», se envía al servidor una marca de tiempo.

Si el servidor no recibe otra confirmación antes de que finalice el intervalo seleccionado, MorningHello puede intentar enviar un aviso a los contactos de emergencia confirmados y activos.

Este aviso no confirma que se haya producido una emergencia.

Los cambios en el perfil, los datos de mascotas, los contactos de emergencia, la suscripción, el estado emocional o los recordatorios no se consideran una confirmación «Estoy bien» y no amplían el intervalo de monitoreo.

9. Información sobre mascotas

La persona usuaria puede guardar voluntariamente información de hasta dos mascotas.

La información puede incluir:
• el nombre de la mascota;
• el tipo de animal;
• información sobre dónde se encuentra;
• instrucciones de alimentación;
• una fotografía del envase del alimento;
• información sobre medicamentos;
• alergias y aspectos importantes de salud;
• información sobre el comportamiento;
• el nombre y número de teléfono de la clínica veterinaria;
• la ubicación de la correa, el transportín y otros objetos necesarios;
• instrucciones adicionales para su cuidado.

Completar el formulario de mascotas es voluntario. La persona usuaria decide la cantidad de información que desea proporcionar.

La información sobre la mascota y la fotografía del alimento pueden transmitirse y almacenarse en los servidores de MorningHello. Después de una confirmación omitida, esta información solo puede proporcionarse a los contactos de emergencia confirmados para ayudarles a organizar la atención de la mascota.

Los datos de la mascota no se revelan a quien paga una suscripción patrocinada únicamente por haber pagado el acceso. Esa persona solo podrá recibirlos si ha sido añadida y confirmada por separado como contacto de emergencia.

La persona usuaria confirma que está autorizada para proporcionar la información y la fotografía cargadas. La fotografía no debe contener documentos de identidad, datos bancarios, contraseñas, códigos de acceso ni otra información que no esté relacionada con el cuidado de la mascota.

MorningHello no es un servicio veterinario y no verifica la exactitud de las instrucciones de alimentación, medicación o cuidado de la mascota.

10. Limitaciones técnicas

MorningHello no garantiza la entrega, puntualidad o recepción de ningún aviso de emergencia.

La persona usuaria es responsable de mantener actualizados los datos de sus contactos, comprobar su conexión y disponer de un método alternativo de comunicación.

La disponibilidad de los servidores, el acceso a internet, App Store, los operadores de telecomunicaciones, los servicios de correo electrónico y las aplicaciones de mensajería puede afectar al funcionamiento de determinadas funciones de MorningHello.

11. Postales y recordatorios

Las postales se proporcionan para uso personal y no comercial.

Las personas usuarias pueden enviarlas mediante iMessage y otras aplicaciones compatibles.

Se prohíbe el uso comercial de las postales sin la autorización escrita de MorningHello.

Los recordatorios de comunicación se almacenan localmente en el dispositivo, no son avisos de emergencia, no se revelan a los contactos de emergencia y no afectan a la fecha límite de la siguiente confirmación «Estoy bien».

12. Propiedad intelectual

El nombre MorningHello, el logotipo, el diseño, la interfaz, los textos, la estructura, el código del software, las colecciones y las postales pertenecen a MorningHello o se utilizan legítimamente.

13. Datos personales

El tratamiento de los datos personales se describe en la Política de Privacidad de MorningHello.

Según las funciones utilizadas, MorningHello puede tratar datos del perfil, el número de teléfono, el país de residencia, información de la suscripción, datos de los contactos de emergencia, datos de monitoreo, información sobre mascotas y una fotografía del envase del alimento.

Los datos se utilizan únicamente para proporcionar las funciones de MorningHello, gestionar las suscripciones y el acceso, realizar el monitoreo del servidor, enviar mensajes del Servicio y avisos de emergencia, aplicar ajustes regionales y ayudar a una mascota después de una confirmación omitida.

Los registros emocionales y los recordatorios de comunicación se almacenan localmente en el dispositivo y no se transmiten al Backend, salvo que la persona usuaria sea informada expresamente antes de que comience dicha transmisión.

Eliminar la Aplicación del iPhone no elimina necesariamente los datos transmitidos anteriormente al servidor.

Para solicitar acceso, corrección o eliminación de los datos personales, la persona usuaria puede escribir a:

krylov.oxana@gmail.com

La eliminación puede estar limitada por obligaciones legales relativas a la conservación de información sobre suscripciones, pagos, seguridad y cumplimiento normativo.

14. Servicios de terceros

El funcionamiento de MorningHello puede depender de Apple, App Store, iOS, Amazon Web Services, Amazon SES, operadores de telecomunicaciones, servicios de correo electrónico y aplicaciones de mensajería.

El uso de estos servicios también puede estar sujeto a sus propias condiciones de uso y políticas de privacidad.

15. Exclusión de garantías

En la medida permitida por la ley, el Servicio se proporciona «tal cual» y «según disponibilidad».

MorningHello no garantiza un funcionamiento ininterrumpido, la entrega de todos los avisos ni la disponibilidad inmediata de un contacto de emergencia.

16. Limitación de responsabilidad

MorningHello no sustituye a los servicios de emergencia, la asistencia médica, veterinaria o social, ni a los métodos alternativos de comunicación.

La persona usuaria es responsable de la exactitud de la información introducida y de mantener actualizados sus contactos de emergencia, número de teléfono, país de residencia e instrucciones para el cuidado de sus mascotas.

17. Legislación aplicable

Estas Condiciones se rigen por las leyes del Estado de Israel, sin limitar los derechos obligatorios de las personas consumidoras que sean aplicables en su lugar de residencia.

18. Versión completa de las Condiciones de Uso

La versión completa y actualizada de las Condiciones de Uso de MorningHello está disponible en el sitio web oficial:

https://www.morninghelloapp.com/terms-and-conditions

Se recomienda revisar el documento completo antes de utilizar la Aplicación.
"""
}
