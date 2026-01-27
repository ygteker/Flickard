import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .bold()
                
                Text("Last updated: January 26, 2026")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Group {
                    SectionHeader(title: "Acceptance of Terms")
                    Text("By downloading, installing, or using Zbam (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.")
                    
                    SectionHeader(title: "Open Source Software")
                    Text("Zbam is free and open-source software. The source code is available for inspection, modification, and contribution. While the app binary is distributed through the App Store, you're free to:")
                    BulletPoint(text: "View and study the source code")
                    BulletPoint(text: "Modify the code for personal use")
                    BulletPoint(text: "Contribute improvements to the project")
                    BulletPoint(text: "Build and distribute your own versions according to the license")
                    
                    Link(destination: URL(string: "https://github.com/ygteker/zbam")!) {
                        HStack {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                            Text("View Source Code on GitHub")
                        }
                        .padding(.top, 4)
                    }
                    
                    SectionHeader(title: "License to Use")
                    Text("You are free to use Zbam for personal, educational, or commercial purposes. The app is provided under an open-source license—please refer to the project repository for specific license terms.")
                    
                    SectionHeader(title: "Permitted Use")
                    Text("You may use Zbam to:")
                    BulletPoint(text: "Create and study flashcards")
                    BulletPoint(text: "Track your study progress")
                    BulletPoint(text: "Customize app settings")
                    BulletPoint(text: "Integrate with other tools or services")
                    BulletPoint(text: "Use for any lawful purpose")
                    
                    SectionHeader(title: "Prohibited Use")
                    Text("You agree not to:")
                    BulletPoint(text: "Use the App for any illegal purpose")
                    BulletPoint(text: "Distribute malicious versions of the App")
                    BulletPoint(text: "Falsely represent yourself as the original author")
                    BulletPoint(text: "Use the App in any way that could harm others")
                }
                
                Group {
                    SectionHeader(title: "User Content")
                    Text("You retain all rights to the flashcard content you create using the App. Your content is stored locally on your device and is not transmitted to our servers.")
                    Text("You are solely responsible for the content you create and the consequences of sharing or using such content.")
                    
                    SectionHeader(title: "Intellectual Property")
                    Text("The App's source code is open source and licensed accordingly (see project repository for details). While you're free to use, modify, and distribute the code according to the license, the \"Zbam\" name and any original design elements remain attributed to the original author.")
                    
                    SectionHeader(title: "Disclaimer of Warranties")
                    Text("The App is provided \"as is\" and \"as available\" without warranties of any kind, either express or implied, including but not limited to:")
                    BulletPoint(text: "Fitness for a particular purpose")
                    BulletPoint(text: "Accuracy or reliability of content")
                    BulletPoint(text: "Uninterrupted or error-free operation")
                    
                    SectionHeader(title: "Limitation of Liability")
                    Text("To the maximum extent permitted by law, the developer shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from:")
                    BulletPoint(text: "Your use or inability to use the App")
                    BulletPoint(text: "Loss of data or content")
                    BulletPoint(text: "Any errors or omissions in the App")
                    
                    SectionHeader(title: "Updates and Changes")
                    Text("We may update the App from time to time to add new features, fix bugs, or improve performance. We may also modify these Terms of Service at any time. Continued use of the App after changes constitutes acceptance of the new terms.")
                }
                
                Group {
                    SectionHeader(title: "Termination")
                    Text("You may stop using the App at any time by uninstalling it from your device. As an open-source project, there are no restrictions on your ability to use the software according to its license terms.")
                    
                    SectionHeader(title: "Governing Law")
                    Text("These Terms of Service shall be governed by and construed in accordance with applicable local laws, without regard to conflict of law principles.")
                    
                    SectionHeader(title: "Severability")
                    Text("If any provision of these Terms is found to be unenforceable or invalid, that provision shall be limited or eliminated to the minimum extent necessary, and the remaining provisions shall remain in full force and effect.")
                    
                    SectionHeader(title: "Contact Information")
                    Text("If you have any questions about these Terms of Service, please contact us through the App Store.")
                    
                    SectionHeader(title: "Acknowledgment")
                    Text("By using Zbam, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.")
                }
                
                Divider()
                
                Text("Thank you for using Zbam!")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
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
        TermsOfServiceView()
    }
}
