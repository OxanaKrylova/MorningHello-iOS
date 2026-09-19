//
//  PostcardCollection.swift
//  MorningHello
//
//  Created by Oxana Krylova on 22/08/2026.
//

import Foundation

enum PostcardCollection: String, CaseIterable, Identifiable {

    case foodTable
    case coffee
    case cats
    case seasonal
    case harvest
    case vacation
    case fairyAnimals
    case flowers
    case sweetTable
    case dogs
    case protestant_church
    case orthodox_church
    case shabbat
    case catholic_church

    var id: String {
        rawValue
    }

    // MARK: - Название коллекции

    var title: String {
        let isEnglish = AppLanguage.selected == .englishUS

        switch self {
        case .protestant_church:
            return L10n.text("Протестантизм")
        case .orthodox_church:
            return isEnglish ? "Orthodox Christianity" : "Православие"
        case .shabbat:
            return isEnglish ? "Judaism" : "Иудаизм"
        case .foodTable:
            return isEnglish ? "Food and Gatherings" : "Вкусный стол"
        case .coffee:
            return isEnglish ? "Morning Coffee" : "Утренний кофе"
        case .cats:
            return isEnglish ? "Cats" : "Коты"
        case .seasonal:
            return isEnglish ? "Season" : "Сезон"
        case .harvest:
            return isEnglish ? "Harvest" : "Урожай"
        case .vacation:
            return isEnglish ? "Vacation" : "Отпуск"
        case .fairyAnimals:
            return isEnglish ? "Fairy Tales" : "Сказка"
        case .flowers:
            return isEnglish ? "Flowers" : "Цветы"
        case .sweetTable:
            return isEnglish ? "Desserts" : "Десерты"
        case .dogs:
            return isEnglish ? "Dogs" : "Собаки"
        case .catholic_church:
            return isEnglish ? "Catholic Christianity" : "Католизм"
        }
    }


    // MARK: - Символ

    var systemImage: String {

        switch self {

        case .protestant_church:
            return "cross.fill"
            
        case .orthodox_church:
            return "building.columns.fill"

        case .shabbat:
            return "sparkles"

        case .foodTable:
            return "fork.knife"

        case .coffee:
            return "cup.and.saucer.fill"

        case .cats:
            return "pawprint.fill"

        case .seasonal:
            return "leaf.fill"

        case .harvest:
            return "basket.fill"

        case .vacation:
            return "sun.max.fill"

        case .fairyAnimals:
            return "wand.and.stars"

        case .flowers:
            return "camera.macro"
            
        case .sweetTable:
            return "birthday.cake.fill"
            
        case .dogs:
            return "pawprint.fill"
            
        case .catholic_church:
            return "building.columns.fill"
        }
    }


    // MARK: - Assets

    var assetNames: [String] {

        switch self {
            
        case .foodTable:

            var foodCards = (1...48).map {
                "Sunday_\($0)"
            }

            foodCards.append(
                "holiday_octoberfest"
            )

            return foodCards
            
            
        case .coffee:

            var coffeeCards = (1...25).map {
                "MondayWarm_\($0)"
            }

            coffeeCards.append(
                contentsOf: (1...24).map {
                    "MondayCold_\($0)"
                }
            )

            coffeeCards.append(
                contentsOf: [
                    "autumn_wednesday",
                    "winter_saturday",
                    "winter_tuesday"
                ]
            )

            return coffeeCards
            
        case .cats:
            
            return
            (1...21).map {
                "November_cat\($0)"
            }
            +
            [
                "holiday_cat",
                "autumn_thursday",
                "autumn_tuesday",
                "spring_tuesday"
            ]
        case .seasonal:
            
            var seasonalCards: [String] =
            (1...18).map {
                "September_\($0)"
            }
            
            seasonalCards.append(
                contentsOf:
                    (1...20).map {
                        "April_\($0)"
                    }
            )
            
            seasonalCards.append(
                contentsOf: [
                    "holiday_autumnal_equinox",
                    "holiday_labor_day",
                    "holiday_elderly_day",
                    "Holiday_Perceids_1",
                    "Holiday_Perceids_2",
                    "Holiday_Perceids_3",
                    "holiday_spring_beginning",
                    "holiday_vernal_equinox",
                    "spring_friday",
                    "winter_friday",
                    "holiday_fishman"
                ]
            )

            return seasonalCards

        case .harvest:
            return (1...20).map {
                "October_\($0)"
            }
            +
            ["holiday_mashrooms"]
            +
            ["holiday_orange"]
            +
            ["holiday_strawberry"]
            
            
        case .vacation:
            
            return (1...19).map {
                "August_\($0)"
            }
            
            
        case .fairyAnimals:
            
            var fairyCards = (1...26).map {
                "December_\($0)"
            }

            fairyCards.append(
                contentsOf: [
                    "holiday_children",
                    "holiday_cosmonautics",
                    "holiday_Potter",
                    "Holiday_teddybear"
                ]
            )

            return fairyCards
            
        case .flowers:
            var flowerCards = (1...18).map {
                "March_\($0)"
            }

            flowerCards.append(
                contentsOf: (1...19).map {
                    String(
                        format: "May_%02d",
                        $0
                    )
                }
            )

            flowerCards.append(
                contentsOf: [
                    "holiday_school_year",
                    "holiday_womens_day",
                    "summer_friday",
                    "summer_saturday",
                    "summer_thursday",
                    "holiday_mimosa",
                    "holiday_rose"
                ]
            )

            return flowerCards
            
        case .sweetTable:
            
            return (1...18).map {
                "February_\($0)"
            }
            +
            ["holiday_friendship"]
            +
            ["Holiday_PancakeDay"]
            +
            ["holiday_valentine"]
            
        case .protestant_church:
            return ProtestantHolidayProvider.assetNames
            
        case .catholic_church:
            
            return [
                "Holiday_Catholic_AdventFriday_1",
                "Holiday_Catholic_AdventFriday_2",
                "Holiday_Catholic_AdventFriday_3",
                "Holiday_Catholic_AdventStart",
                "Holiday_Catholic_AshWednesday",
                "Holiday_Catholic_Assumption",
                "Holiday_Catholic_LentFriday_1",
                "Holiday_Catholic_LentFriday_2",
                "Holiday_Catholic_LentFriday_3",
                "Holiday_Catholic_LentFriday_4",
                "Holiday_Catholic_PalmSunday",
                "Holiday_catholic_passover",
                "Catholic_Good_Friday",
                "Catholic_Holy_Monday",
                "Catholic_Holy_Saturday",
                "Catholic_Holy_Thursday",
                "Catholic_Holy_Tuesday",
                "Catholic_Holy_Wednesday",
                "holiday_ Ascension",
                "holiday_AllSaints",
                "holiday_annunciation",
                "holiday_Conception",
                "holiday_epithany",
                "Holiday_LaSaint_Jean",
                "holiday_Passover",
                "holiday_thanksgiving",
                "Holiday_Tranfiguration",
                "holiday_trinity"
            ]
            
        case .orthodox_church:
            
            return [
                "Orthodox_BeginningDormitionFast",
                "Orthodox_BeginningNativityFast",
                "Orthodox_ChristmasEve",
                "Orthodox_Clean Monday",
                "Orthodox_EveDormition",
                "Orthodox_FeastSaintsPeterPaul",
                "Orthodox_FinalDayApostlesFast",
                "Orthodox_FirstFridayafterCleanMonday",
                "Orthodox_FirstMondayGreatLent",
                "Orthodox_Holy Friday",
                "Orthodox_Holy Monday",
                "Orthodox_Holy Saturday",
                "Orthodox_Holy Thursday",
                "Orthodox_Holy Tuesday",
                "Orthodox_Holy Wednesday",
                "Orthodox_LazarusSaturday",
                "Orthodox_MondayafterAllSaints",
                "Orthodox_Pentecost",
                "Holiday_Apple",
                "holiday_baptism",
                "holiday_dormition",
                "holiday_easter",
                "holiday_epiphany",
                "Holiday_ForgivenSunday",
                "holiday_meeting",
                "holiday_orthodox_christmas",
                "holiday_palm_sunday"
            ]


        case .shabbat:

            return [
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
                "Shabbat_11",
                "hanuka_lights_1",
                "hanuka_lights_2",
                "hanuka_lights_3",
                "hanuka_lights_4",
                "hanuka_lights_5",
                "hanuka_lights_6",
                "hanuka_lights_7",
                "hanuka_lights_8",
                "holiday_lagbaomer",
                "holiday_purim",
                "holiday_rosh",
                "holiday_Simha_Tora",
                "holiday_TishaBAv",
                "holiday_yom_kippor",
                "Judaism_FastEsther",
                "Judaism_FastGedaliah",
                "Judaism_SeventeenthTammuz",
                "Judaism_TenthTevet",
                "Sukkot_1",
                "Sukkot_2",
                "Sukkot_3",
                "Sukkot_4",
                "Sukkot_5",
                "Sukkot_6",
                "Sukkot_7"
            ]

        case .dogs:
            
            return (1...20).map {
                "January_\($0)"}
                +
                ["holiday_dog"]
            +
            ["spring_saturday"]
            +
            ["spring_thursday"]
            +
            ["spring_wednesday"]
        }
    }
}
