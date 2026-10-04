import Foundation

enum RegionalEmergencyCatalog {

    static func directory(
        for countryCode: String
    ) -> CountryEmergencyDirectory? {

        let services = records
            .filter {
                $0.countryCode == countryCode
            }
            .map {
                makeService($0)
            }

        guard !services.isEmpty else {
            return nil
        }

        return CountryEmergencyDirectory(
            countryCode: countryCode,
            services: services
        )
    }

    private struct Record {
        let countryCode: String
        let kind: CountryEmergencyServiceKind
        let number: String
        let sourceSlug: String?
        let noteKey: String?

        init(
            _ countryCode: String,
            _ kind: CountryEmergencyServiceKind,
            _ number: String,
            _ sourceSlug: String? = nil,
            noteKey: String? = nil
        ) {
            self.countryCode = countryCode
            self.kind = kind
            self.number = number
            self.sourceSlug = sourceSlug
            self.noteKey = noteKey
        }
    }

    private static let records: [Record] = [

        // MARK: Русскоязычный регион бывшего СССР

        Record(
            "AM",
            .general,
            "911",
            "armenia"
        ),

        Record(
            "AZ",
            .ambulance,
            "103",
            "azerbaijan"
        ),
        Record(
            "AZ",
            .fire,
            "101",
            "azerbaijan"
        ),
        Record(
            "AZ",
            .police,
            "102",
            "azerbaijan"
        ),

        Record(
            "BY",
            .ambulance,
            "103",
            "belarus"
        ),
        Record(
            "BY",
            .fire,
            "101",
            "belarus"
        ),
        Record(
            "BY",
            .police,
            "102",
            "belarus"
        ),

        Record(
            "GE",
            .general,
            "112",
            "georgia"
        ),

        Record(
            "KZ",
            .general,
            "112",
            "kazakhstan"
        ),
        Record(
            "KZ",
            .ambulance,
            "103",
            "kazakhstan"
        ),
        Record(
            "KZ",
            .fire,
            "101",
            "kazakhstan"
        ),
        Record(
            "KZ",
            .police,
            "102",
            "kazakhstan"
        ),

        Record(
            "KG",
            .general,
            "112",
            "kyrgyzstan"
        ),
        Record(
            "KG",
            .ambulance,
            "103",
            "kyrgyzstan"
        ),
        Record(
            "KG",
            .fire,
            "101",
            "kyrgyzstan"
        ),
        Record(
            "KG",
            .police,
            "102",
            "kyrgyzstan"
        ),

        Record(
            "MD",
            .general,
            "112",
            "moldova"
        ),

        Record(
            "RU",
            .general,
            "112",
            "russia"
        ),

        Record(
            "TJ",
            .ambulance,
            "103",
            "tajikistan"
        ),
        Record(
            "TJ",
            .fire,
            "101",
            "tajikistan"
        ),
        Record(
            "TJ",
            .police,
            "102",
            "tajikistan"
        ),

        Record(
            "TM",
            .ambulance,
            "003",
            "turkmenistan"
        ),
        Record(
            "TM",
            .fire,
            "001",
            "turkmenistan"
        ),
        Record(
            "TM",
            .police,
            "002",
            "turkmenistan"
        ),

        Record(
            "UA",
            .ambulance,
            "103",
            "ukraine"
        ),
        Record(
            "UA",
            .fire,
            "101",
            "ukraine"
        ),
        Record(
            "UA",
            .police,
            "102",
            "ukraine"
        ),

        Record(
            "UZ",
            .general,
            "112",
            "uzbekistan"
        ),
        Record(
            "UZ",
            .ambulance,
            "103",
            "uzbekistan"
        ),
        Record(
            "UZ",
            .fire,
            "101",
            "uzbekistan"
        ),
        Record(
            "UZ",
            .police,
            "102",
            "uzbekistan"
        ),

        // MARK: Латинская Америка

        Record(
            "AR",
            .ambulance,
            "107",
            "argentina"
        ),
        Record(
            "AR",
            .fire,
            "100",
            "argentina"
        ),
        Record(
            "AR",
            .police,
            "911",
            "argentina"
        ),

        Record(
            "BO",
            .ambulance,
            "118",
            "bolivia"
        ),
        Record(
            "BO",
            .fire,
            "119",
            "bolivia"
        ),
        Record(
            "BO",
            .police,
            "110",
            "bolivia"
        ),

        Record(
            "BR",
            .ambulance,
            "192",
            "brazil"
        ),
        Record(
            "BR",
            .fire,
            "193",
            "brazil"
        ),
        Record(
            "BR",
            .police,
            "190",
            "brazil"
        ),

        Record(
            "CL",
            .ambulance,
            "131",
            "chile"
        ),
        Record(
            "CL",
            .fire,
            "132",
            "chile"
        ),
        Record(
            "CL",
            .police,
            "133",
            "chile"
        ),

        Record(
            "CO",
            .general,
            "123",
            "colombia"
        ),
        Record(
            "CO",
            .fire,
            "119",
            "colombia"
        ),

        Record(
            "CR",
            .general,
            "911",
            "costa-rica"
        ),

        Record(
            "CU",
            .ambulance,
            "104",
            "cuba"
        ),
        Record(
            "CU",
            .fire,
            "105",
            "cuba"
        ),
        Record(
            "CU",
            .police,
            "106",
            "cuba"
        ),

        Record(
            "DO",
            .general,
            "911",
            "dominican-republic",
            noteKey:
                "emergency.note.do.coverage"
        ),

        Record(
            "EC",
            .general,
            "911",
            "ecuador"
        ),

        Record(
            "SV",
            .general,
            "911",
            "el-salvador"
        ),

        Record(
            "GT",
            .general,
            "122",
            "guatemala"
        ),
        Record(
            "GT",
            .general,
            "123",
            "guatemala"
        ),
        Record(
            "GT",
            .police,
            "110",
            "guatemala"
        ),

        Record(
            "HT",
            .ambulance,
            "116",
            "haiti",
            noteKey:
                "emergency.note.ht.delay"
        ),
        Record(
            "HT",
            .fire,
            "115",
            "haiti",
            noteKey:
                "emergency.note.ht.delay"
        ),
        Record(
            "HT",
            .police,
            "122",
            "haiti",
            noteKey:
                "emergency.note.ht.delay"
        ),

        Record(
            "HN",
            .general,
            "911",
            "honduras"
        ),

        Record(
            "MX",
            .general,
            "911",
            "mexico"
        ),

        Record(
            "NI",
            .general,
            "911",
            "nicaragua"
        ),

        Record(
            "PA",
            .general,
            "911",
            "panama"
        ),
        Record(
            "PA",
            .ambulance,
            "103",
            "panama"
        ),
        Record(
            "PA",
            .fire,
            "103",
            "panama"
        ),
        Record(
            "PA",
            .police,
            "104",
            "panama"
        ),

        Record(
            "PY",
            .ambulance,
            "141",
            "paraguay"
        ),
        Record(
            "PY",
            .fire,
            "132",
            "paraguay"
        ),
        Record(
            "PY",
            .police,
            "911",
            "paraguay"
        ),

        Record(
            "PE",
            .ambulance,
            "106",
            "peru"
        ),
        Record(
            "PE",
            .fire,
            "116",
            "peru"
        ),
        Record(
            "PE",
            .police,
            "105",
            "peru"
        ),

        Record(
            "UY",
            .general,
            "911",
            "uruguay"
        ),

        Record(
            "VE",
            .general,
            "911",
            "venezuela"
        ),

        // MARK: Дополнительные страны и территории региона

        Record(
            "BZ",
            .general,
            "911",
            "belize"
        ),

        Record(
            "GY",
            .ambulance,
            "913",
            "guyana"
        ),
        Record(
            "GY",
            .fire,
            "912",
            "guyana"
        ),
        Record(
            "GY",
            .police,
            "911",
            "guyana"
        ),

        Record(
            "SR",
            .general,
            "115",
            "suriname"
        ),

        Record(
            "PR",
            .general,
            "911"
        )
    ]

    private static func makeService(
        _ record: Record
    ) -> CountryEmergencyService {

        let source = sourceData(
            for: record
        )

        return CountryEmergencyService(
            id: identifier(
                for: record
            ),
            kind: record.kind,
            number: record.number,
            noteKey: record.noteKey,
            sourceName: source.name,
            sourceURL: source.url,
            verifiedAt:
                "2026-10-03"
        )
    }

    private static func sourceData(
        for record: Record
    ) -> (
        name: String,
        url: URL
    ) {

        if record.countryCode == "PR" {
            return (
                name: "911.gov",
                url: URL(
                    string:
                        "https://www.911.gov/calling-911/"
                )!
            )
        }

        let slug =
            record.sourceSlug ?? ""

        return (
            name: "FCDO",
            url: URL(
                string:
                    "https://www.gov.uk/foreign-travel-advice/\(slug)/getting-help"
            )!
        )
    }

    private static func identifier(
        for record: Record
    ) -> String {

        let normalizedNumber =
            record.number.filter(
                \.isNumber
            )

        return
            "\(record.countryCode)-\(record.kind.rawValue)-\(normalizedNumber)"
    }
}
