//
//  InfoView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 09.08.2024.
//

import SwiftUI

struct InfoView: View {
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                let version = Bundle.main.object(forInfoDictionaryKey: Constants.aboutVersionKey) as? String
                let data = Data(base64Encoded: Constants.aboutSupportMail)
                let mail = String(data: data!, encoding: .utf8) ?? String()
                
                Text(String(format: Constants.aboutVersion, version!))
                    .font(.system(size: 18))
                    .padding(.top, 60)
                    .padding(.leading, 20)
                HStack {
                    Text(Constants.aboutGetSupport)
                    Link(mail, destination: URL(string: String(format: Constants.aboutMailTo, mail))!)
                        .buttonStyle(.plain)
                        .focusEffectDisabled()
                }
                .padding(.top, 80)
                Link(Constants.aboutGitHub, destination: URL(string: Constants.aboutGitHubLink)!)
                    .focusEffectDisabled()
            }
            .padding(.top, 5)
            .padding(.leading, 170)
        }
        .frame(width: 380, height: 250)
        .background() {
            Image(nsImage: NSImage(named: Constants.aboutBackground) ?? NSImage())
                .resizable()
                .frame(minWidth: 380, maxWidth: 380, minHeight: 250, maxHeight: 250)
        }
    }
}

#Preview {
    InfoView()
}
