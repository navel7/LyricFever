//
//  KaraokeView.swift
//  Lyric Fever
//
//  Created by Avi Wadhwa on 2024-10-08.
//

import SwiftUI
import SDWebImage
import ColorKit
import Combine

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()

        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        //
        nsView.material = .hudWindow
        nsView.blendingMode = .behindWindow
    }
}

private struct KaraokeWidthClip: AnimatableModifier {
    var width: CGFloat

    var animatableData: CGFloat {
        get { width }
        set { width = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(width: max(width, 0)).clipped()
    }
}

@available(macOS 26.0, *)
private final class KaraokeGlassView<Content: View>: NSGlassEffectView {
    private let clippingView = NSView()
    private let hostingView: NSHostingView<Content>
    var contentWidth: CGFloat = 0

    init(content: Content) {
        hostingView = NSHostingView(rootView: content)
        super.init(frame: .zero)
        style = .clear
        clippingView.wantsLayer = true
        clippingView.layer?.masksToBounds = true
        clippingView.addSubview(hostingView)
        contentView = clippingView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(content: Content, width: CGFloat, tint: NSColor) {
        hostingView.rootView = content
        contentWidth = width
        tintColor = tint
        needsLayout = true
    }

    override func layout() {
        super.layout()
        cornerRadius = bounds.height / 2
        clippingView.frame = bounds
        clippingView.layer?.cornerRadius = bounds.height / 2
        hostingView.frame = NSRect(x: (bounds.width - contentWidth) / 2, y: 2,
                                   width: contentWidth, height: bounds.height)
    }
}

@available(macOS 26.0, *)
private struct KaraokeGlass<Content: View>: NSViewRepresentable {
    let content: Content
    let contentWidth: CGFloat
    let tint: NSColor

    func makeNSView(context: Context) -> KaraokeGlassView<Content> {
        KaraokeGlassView(content: content)
    }

    func updateNSView(_ view: KaraokeGlassView<Content>, context: Context) {
        view.update(content: content, width: contentWidth, tint: tint)
    }
}

@available(macOS 26.0, *)
private struct KaraokeGlassLayout<Lyric: View>: AnimatableModifier {
    var width: CGFloat
    let targetWidth: CGFloat
    let tint: NSColor
    let lyric: Lyric

    var animatableData: CGFloat {
        get { width }
        set { width = newValue }
    }

    func body(content: Content) -> some View {
        content.hidden()
            .overlay {
                KaraokeGlass(content: lyric, contentWidth: targetWidth, tint: tint)
                    .frame(width: max(width, 0))
            }
            .frame(width: max(width, 0))
    }
}

private struct KaraokeLyricSegment {
    let text: String
    let fontSize: CGFloat
}

struct KaraokeView: View {
    @Environment(ViewModel.self) var viewmodel
    @State private var displayedPillWidth: CGFloat?
    @AppStorage("karaokeTransparency") var karaokeTransparency: Double = 50
    @AppStorage("karaokeShowMultilingual") var karaokeShowMultilingual: Bool = true
    @AppStorage("karaokeUseAlbumColor") var karaokeUseAlbumColor: Bool = true
    @AppStorage("fixedKaraokeColorHex") var fixedKaraokeColorHex: String = "#2D3CCC"
    
    func currentWords(for currentlyPlayingLyricsIndex: Int) -> String {
        if !viewmodel.romanizedLyrics.isEmpty {
            return viewmodel.romanizedLyrics[currentlyPlayingLyricsIndex]
        } else if !viewmodel.chineseConversionLyrics.isEmpty {
            return viewmodel.chineseConversionLyrics[currentlyPlayingLyricsIndex]
        } else {
            return viewmodel.currentlyPlayingLyrics[currentlyPlayingLyricsIndex].words
        }
    }
    
    func multilingualView(_ currentlyPlayingLyricsIndex: Int) -> some View {
        VStack(spacing: 6) {
            Text(verbatim: currentWords(for: currentlyPlayingLyricsIndex))
                
//            Text(verbatim: viewmodel.romanizedLyrics.isEmpty ? viewmodel.currentlyPlayingLyrics[currentlyPlayingLyricsIndex].words : viewmodel.romanizedLyrics[currentlyPlayingLyricsIndex])
            Text(verbatim: viewmodel.translatedLyric[currentlyPlayingLyricsIndex])
                .font(.custom(viewmodel.karaokeFont.fontName, size: 0.9*(viewmodel.karaokeFont.pointSize)))
                .opacity(0.85)
        }
    }
    
    func originalAndTranslationAreDifferent(for currentlyPlayingLyricsIndex: Int) -> Bool {
        viewmodel.currentlyPlayingLyrics[currentlyPlayingLyricsIndex].words != viewmodel.translatedLyric[currentlyPlayingLyricsIndex]
    }

    private var currentLyricSegments: [KaraokeLyricSegment] {
        guard let currentlyPlayingLyricsIndex = viewmodel.currentlyPlayingLyricsIndex else {
            return []
        }

        let mainFontSize = viewmodel.karaokeFont.pointSize
        if viewmodel.translationExists {
            if karaokeShowMultilingual, originalAndTranslationAreDifferent(for: currentlyPlayingLyricsIndex) {
                return [
                    KaraokeLyricSegment(text: currentWords(for: currentlyPlayingLyricsIndex), fontSize: mainFontSize),
                    KaraokeLyricSegment(text: viewmodel.translatedLyric[currentlyPlayingLyricsIndex], fontSize: mainFontSize * 0.9)
                ]
            }
            return [KaraokeLyricSegment(text: viewmodel.translatedLyric[currentlyPlayingLyricsIndex], fontSize: mainFontSize)]
        }

        if !viewmodel.romanizedLyrics.isEmpty {
            return [KaraokeLyricSegment(text: viewmodel.romanizedLyrics[currentlyPlayingLyricsIndex], fontSize: mainFontSize)]
        }
        if !viewmodel.chineseConversionLyrics.isEmpty {
            return [KaraokeLyricSegment(text: viewmodel.chineseConversionLyrics[currentlyPlayingLyricsIndex], fontSize: mainFontSize)]
        }
        return [KaraokeLyricSegment(text: viewmodel.currentlyPlayingLyrics[currentlyPlayingLyricsIndex].words, fontSize: mainFontSize)]
    }

    var hasVisibleCurrentLyric: Bool {
        currentLyricSegments.contains { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func measuredWidth(for segment: KaraokeLyricSegment) -> CGFloat {
        let font = NSFont(name: viewmodel.karaokeFont.fontName, size: segment.fontSize) ?? viewmodel.karaokeFont
        return segment.text
            .components(separatedBy: .newlines)
            .map { ($0 as NSString).size(withAttributes: [.font: font]).width }
            .max() ?? 0
    }

    var karaokePillWidth: CGFloat {
        guard hasVisibleCurrentLyric else {
            return 0
        }
        let textWidth = currentLyricSegments.map { measuredWidth(for: $0) }.max() ?? 0
        return min(max(textWidth + 12, 0), 760) + 40
    }

    private var visiblePillWidth: CGFloat {
        displayedPillWidth ?? karaokePillWidth
    }
    
    @ViewBuilder
    func lyricsView() -> some View {
        if let currentlyPlayingLyricsIndex = viewmodel.currentlyPlayingLyricsIndex {
            if viewmodel.translationExists {
                if karaokeShowMultilingual, originalAndTranslationAreDifferent(for: currentlyPlayingLyricsIndex) {
                    multilingualView(currentlyPlayingLyricsIndex)
                }
                else {
                    Text(verbatim: viewmodel.translatedLyric[currentlyPlayingLyricsIndex])
                }
            } else {
                if !viewmodel.romanizedLyrics.isEmpty {
                    Text(verbatim: viewmodel.romanizedLyrics[currentlyPlayingLyricsIndex])
                } else if !viewmodel.chineseConversionLyrics.isEmpty {
                    Text(verbatim: viewmodel.chineseConversionLyrics[currentlyPlayingLyricsIndex])
                } else {
                    Text(verbatim: viewmodel.currentlyPlayingLyrics[currentlyPlayingLyricsIndex].words)
                }
            }
        } else {
            Text("")
        }
    }
    
    var karaokeLyricsText: some View {
        lyricsView()
            .lineLimit(2)
            .foregroundStyle(.white)
            .minimumScaleFactor(0.9)
            .font(.custom(viewmodel.karaokeFont.fontName, size: viewmodel.karaokeFont.pointSize))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    var karaokePillContent: some View {
        Group {
            if hasVisibleCurrentLyric {
                if #available(macOS 26.0, *) {
                    karaokePillLayout
                        .modifier(KaraokeGlassLayout(
                            width: visiblePillWidth,
                            targetWidth: karaokePillWidth,
                            tint: NSColor(currentAlbumArt.opacity(karaokeTransparency / 100)),
                            lyric: karaokePillLayout
                        ))
                } else {
                    karaokePillLayout
                        .modifier(KaraokeWidthClip(width: visiblePillWidth))
                        .background {
                            currentAlbumArt
                                .opacity(karaokeTransparency / 100)
                                .background(VisualEffectView().ignoresSafeArea())
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            } else {
                Color.clear.frame(width: 0, height: 100)
            }
        }
        .onAppear {
            displayedPillWidth = karaokePillWidth
        }
        .onChange(of: karaokePillWidth) { _, newWidth in
            withAnimation(.easeIn(duration: 0.2)) {
                displayedPillWidth = newWidth
            }
        }
    }

    private var karaokePillLayout: some View {
        karaokeLyricsText
            .frame(width: max(karaokePillWidth - 40, 0))
            .padding(10)
            .padding(.horizontal, 10)
            .onHover { hover in
                if viewmodel.userDefaultStorage.karaokeModeHoveringSetting {
                    viewmodel.karaokeModeHovering = hover
                }
            }
    }

    @ViewBuilder
    var finalKaraokeView: some View {
        karaokePillContent
        .frame(minWidth: 800, maxWidth: 800, minHeight: 100, maxHeight: 100, alignment: .center)
        .clipped()
    }
    
    var currentAlbumArt: Color {
        // ensure user wants to use album-derived color, and album-derived color exists
        guard karaokeUseAlbumColor, let currentBackground = viewmodel.currentBackground else {
            return Color(NSColor(hexString: fixedKaraokeColorHex)!)
        }
        return currentBackground
    }
    
    var body: some View {
        finalKaraokeView
    }
}
