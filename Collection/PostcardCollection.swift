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
    case autumn
    case harvest
    case vacation
    case fairyAnimals
    case flowers
    case sweetTable
    case dogs
    case orthodox_church
    case shabbat
    case catholic_church

    var id: String {
        rawValue
    }

    // MARK: - Название коллекции

    var title: String {

        switch self {

        case .orthodox_church:
            return "Православие"

        case .shabbat:
            return "Иудаизм"

        case .foodTable:
            return "Вкусный стол"

        case .coffee:
            return "Утренний кофе"

        case .cats:
            return "Коты"

        case .autumn:
            return "Сезоны"

        case .harvest:
            return "Урожай"

        case .vacation:
            return "Отпуск"

        case .fairyAnimals:
            return "Сказка"
       
        case .flowers:
            return "Цветы"
        
        case .sweetTable:
            return "Десерты"
           
        case .dogs:
            return "Собаки"
            
        case .catholic_church:
            return "Католицизм"
        }
    }


    // MARK: - Символ

    var systemImage: String {

        switch self {

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

        case .autumn:
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
            return (1...48).map {
                "Sunday_\($0)"
            }
            
            
        case .coffee:
            
            return
            (1...25).map {
                "MondayWarm_\($0)"
            }
            +
            (1...24).map {
                "MondayCold_\($0)"
            }
            +
            ["autumn_wednesday"]
            +
            ["winter_saturday"]
            +
            ["winter_tuesday"]
            
        case .cats:
            
            return (1...21).map {
                "November_cat\($0)"}
            +
            ["holiday_cat"]
            +
            ["autumn_thursday"]
            +
            ["autumn_tuesday"]
            +
            ["spring_tuesday"]
                        
        case .autumn:

            var autumnCards: [String] = (1...18).map {
                "September_\($0)"
            }

            return (1...20).map {
                "April\($0)"}
            
            autumnCards.append(
                "holiday_autumnal_equinox"
            )

            autumnCards.append(
                "holiday_labor_day"
            )

            autumnCards.append(
                "Holiday_Perceids_1"
            )
            
            autumnCards.append(
                "Holiday_Perceids_2"
            )
            autumnCards.append(
                "Holiday_Perceids_3"
            )
            autumnCards.append(
                "holiday_spring_beginning"
            )
            autumnCards.append(
                "holiday_vernal_equinox"
            )
            autumnCards.append(
                "spring_friday"
            )
            autumnCards.append(
                "winter_friday"
            )
            autumnCards.append(
                "holiday_elderly_day"
            )
            return autumnCards

        case .harvest:
            
            return (1...20).map {
                "October_\($0)"
            }
            
            
        case .vacation:
            
            return (1...19).map {
                "August_\($0)"
            }
            
            
        case .fairyAnimals:
            
            return (1...26).map {
                "December_\($0)"
            }
            +
            ["holiday_children"]
            +
            ["holiday_cosmonautics"]
            +
            ["holiday_Potter"]
            +
            ["Holiday_teddybear"]
            
        case .flowers:
            
            return (1...18).map {
                "March_\($0)"
            }
            +
            ["holiday_school_year"]
            +
            ["holiday_womens_day"]
            +
            ["summer_friday"]
            +
            ["summer_saturday"]
            +
            ["summer_thursday"]
            
            
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
