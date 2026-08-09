//
//  AppEntryView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/08/2026.
//

import Foundation
import SwiftUI

struct AppEntryView: View {
    
    private let currentTermsVersion = "1.0"
    
    @AppStorage("accepted_terms_version")
    private var acceptedTermsVersion = ""
    
    @AppStorage("profile_display_name")
    private var displayName = ""
    
    @AppStorage("profile_birth_day")
    private var birthDay = 0
    
    @AppStorage("profile_birth_month")
    private var birthMonth = 0
    
    @AppStorage("profile_salutation")
    private var savedSalutation = ""
    
    @AppStorage("check_in_interval_hours")
    private var checkInIntervalHours = 0
    
    @AppStorage("check_in_interval_confirmed")
    private var checkInIntervalConfirmed = false
    
    @AppStorage("contacts_onboarding_completed")
    private var contactsOnboardingCompleted = false
    
    @State private var hasEmergencyContacts = false
        
        var body: some View {
            Group {
                
                // Шаг 1 — Условия использования
                if acceptedTermsVersion != currentTermsVersion {
                    
                    TermsOfUseView {
                        acceptedTermsVersion =
                        currentTermsVersion
                    }
                    
                    // Шаг 2 — Профиль
                } else if !isProfileComplete {
                    
                    ProfileView()
                    
                    // Шаг 3 — Тревожные контакты
                } else if !contactsOnboardingCompleted {
                    EmergencyContactsView(
                        isOnboarding: true,
                        onOnboardingComplete: {
                            contactsOnboardingCompleted = true
                            refreshEmergencyContacts()
                        }
                    )
                } else {
                    ContentView()
                }
                // Онбординг закончен
            }
            .onAppear {
                refreshEmergencyContacts()
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UserDefaults.didChangeNotification
                )
            ) { _ in
                refreshEmergencyContacts()
            }
        }
        
        private var isProfileComplete: Bool {
            let trimmedName =
            displayName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            
            let trimmedSalutation =
            savedSalutation.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            
            return
            !trimmedName.isEmpty &&
            !trimmedSalutation.isEmpty &&
            birthDay > 0 &&
            birthMonth > 0 &&
            checkInIntervalHours > 0 &&
            checkInIntervalConfirmed
        }
        
        private func refreshEmergencyContacts() {
            guard let data =
                    UserDefaults.standard.data(
                        forKey: "emergency_contacts"
                    ),
                  let contacts =
                    try? JSONDecoder().decode(
                        [EmergencyContact].self,
                        from: data
                    )
            else {
                hasEmergencyContacts = false
                return
            }
            
            hasEmergencyContacts =
            !contacts.isEmpty
        }
    }
