//
//  PrivacyPolicyView.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 26.01.26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()
                
                Text("Last updated: January 26, 2026")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Group {
                    SectionHeader(title: "Overview")
                    Text("Zbam is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our flashcard application.")
                    
                    SectionHeader(title: "Data Collection")
                    Text("Zbam is designed with privacy as a priority. We do not collect, transmit, or store any of your personal information on external servers.")
                    
                    SectionHeader(title: "Local Storage")
                    Text("All flashcard data you create is stored locally on your device using Apple's SwiftData framework. This includes:")
                    BulletPoint(text: "Flashcard content (front and back text)")
                    BulletPoint(text: "Your study progress and statistics")
                    BulletPoint(text: "App settings and preferences")
                    Text("This data never leaves your device and is not accessible to us or any third parties.")
                    
                    SectionHeader(title: "Analytics and Logging")
                    Text("We may collect anonymous usage data and crash reports through Apple's built-in analytics system to improve app performance and stability. This data includes:")
                    BulletPoint(text: "Device model and iOS version")
                    BulletPoint(text: "Crash reports and performance metrics")
                    BulletPoint(text: "General app usage statistics (e.g., navigation patterns, feature usage)")
                    Text("This data is collected only if you have opted in to share analytics with Apple in your device settings (Settings → Privacy & Security → Analytics & Improvements).")
                    Text("The app uses local logging for debugging purposes. These logs remain on your device and are only accessible to Apple if you share diagnostic data, or if you manually provide them when reporting a bug.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("This data is anonymous and cannot be used to identify you personally.")
                        .italic()
                }
                
                Group {
                    SectionHeader(title: "What We Don't Collect")
                    Text("We do not collect:")
                    BulletPoint(text: "Your name, email, or contact information")
                    BulletPoint(text: "Your flashcard content")
                    BulletPoint(text: "Your location data")
                    BulletPoint(text: "Your browsing history or activity in other apps")
                    BulletPoint(text: "Any personally identifiable information")
                    
                    SectionHeader(title: "Third-Party Services")
                    Text("Zbam does not use any third-party analytics, advertising, or tracking services. Your data stays on your device.")
                    
                    SectionHeader(title: "Data Security")
                    Text("Your flashcard data is protected by your device's security features, including device passcode and biometric authentication (Face ID/Touch ID). We recommend keeping your device secure to protect your data.")
                    
                    SectionHeader(title: "Children's Privacy")
                    Text("Zbam does not knowingly collect any information from children. The app is designed to be safe for users of all ages.")
                    
                    SectionHeader(title: "Changes to This Policy")
                    Text("We may update this Privacy Policy from time to time. Any changes will be posted in this section of the app, and the \"Last updated\" date will be revised accordingly.")
                    
                    SectionHeader(title: "Contact Us")
                    Text("If you have any questions about this Privacy Policy, please contact us through the App Store.")
                }
                
                Divider()
                
                Text("By using Zbam, you agree to this Privacy Policy.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views

private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .padding(.top, 8)
    }
}

private struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
        .padding(.leading, 8)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
