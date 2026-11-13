//
//  KaraokeSettings.swift
//  Lyric Fever
//
//  Created by Avi Wadhwa on 2025-02-08.
//

import SwiftUI
import AppKit
import FontPicker

struct KaraokeSettingsView: View {
    @Environment(ViewModel.self) var viewmodel
    @AppStorage("karaokeUseAlbumColor") var karaokeUseAlbumColor: Bool = true
    @AppStorage("fixedKaraokeColorHex") var fixedKaraokeColorHex: String = "#2D3CCC"
    @AppStorage("karaokeModeHoveringSetting") var karaokeModeHoveringSetting: Bool = false
    @AppStorage("karaokeShowMultilingual") var karaokeShowMultilingual: Bool = true
    @AppStorage("karaokeTransparency") var karaokeTransparency: Double = 50
    @AppStorage("karaokeTimingAdjustment") var karaokeTimingAdjustment: Double = -0.5

    private var timingDescription: String {
        if abs(karaokeTimingAdjustment) < 0.05 { return String(localized: "Original timing") }
        let seconds = abs(karaokeTimingAdjustment).formatted(.number.precision(.fractionLength(2)))
        return String(localized: "\(seconds) s earlier")
    }
    
    var colorBinding: Binding<Color> {
        Binding<Color> {
            Color(NSColor(hexString: fixedKaraokeColorHex)!)
        } set: { newValue in
            fixedKaraokeColorHex = NSColor(newValue).hexString!
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            @Bindable var viewmodel = viewmodel
            Text("Karaoke Behaviour")
                .font(.system(size: 15, weight: .bold))
            Toggle(isOn: $karaokeModeHoveringSetting) {
                Text("Hide Karaoke window when mouse passes by")
            }
            .toggleStyle(.checkbox)
            Toggle(isOn: $karaokeShowMultilingual) {
                Text("Show multilingual lyrics when translating in Karaoke window")
            }
            .toggleStyle(.checkbox)
            .padding(.bottom, 20)
            
            Text("Lyric timing: \(timingDescription)")
            HStack {
                Text("Earlier")
                Slider(value: $karaokeTimingAdjustment, in: -2...0, step: 0.25)
                    .accessibilityLabel("Karaoke lyric timing")
                    .accessibilityValue(timingDescription)
                Text("Original")
            }
            .frame(width: 300)
            .padding(.bottom, 20)

            Text("Karaoke Background Appearance")
                    .font(.system(size: 15, weight: .bold))
            
            Toggle(isOn: $karaokeUseAlbumColor) {
                Text("Use album color for Karaoke window")
            }
            .toggleStyle(.checkbox)
            if !karaokeUseAlbumColor {
                ColorPicker("Set a background color", selection: colorBinding, supportsOpacity: false)
            }
            Text("Opacity Level")
            HStack {
                Image(systemName: "circle")
                    .accessibilityHidden(true)
                Slider(value: $karaokeTransparency, in: 1...100, step: 5)
                    .accessibilityLabel("Opacity Level")
                    .accessibilityValue("\(Int(karaokeTransparency)) percent")
                Image(systemName: "circle.fill")
                    .accessibilityHidden(true)
            }
            .frame(width: 300, height: 24)
            .padding(.bottom, 20)
            
            Text("Karaoke Font Appearance")
//                .bold()
                .font(.system(size: 15, weight: .bold))
            FontPicker("Select a Font:", selection: $viewmodel.karaokeFont)
                .frame(height: 30)
                .buttonStyle(.bordered)
            Text("Font Selected: \(viewmodel.karaokeFont.displayName ?? ""), Size: \(Int(viewmodel.karaokeFont.pointSize))")
                .font(.custom(viewmodel.karaokeFont.fontName, size: 13))
            
            .frame(width: 300, height: 24)
            Button("Reset to default") {
                viewmodel.userDefaultStorage.karaokeModeHoveringSetting = false
                karaokeUseAlbumColor = true
                karaokeTimingAdjustment = -0.5
                viewmodel.userDefaultStorage.karaokeShowMultilingual = true
                viewmodel.userDefaultStorage.karaokeTransparency = 50
                viewmodel.karaokeFont = NSFont.boldSystemFont(ofSize: 30)
//                viewmodel.karaokeFontSize = 30
                colorBinding.wrappedValue = Color(.sRGB, red: 0.98, green: 0.0, blue: 0.98)
                
            }
            Spacer()
        }
//        .padding(.vertical, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.bouncy, value: karaokeUseAlbumColor)
        .padding(.horizontal)
        .padding(.top, 100)
    }
}
