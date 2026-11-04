//
//  FloatingPanel.swift
//  Lyric Fever
//
//  Created by Avi Wadhwa on 2024-10-29.
//

// Taken from the Cindori blog, updated to fit my needs

import SwiftUI

extension View {
    func floatingPanel<Content: View>(isPresented: Binding<Bool>,
                                      contentRect: CGRect = CGRect(x: 0, y: 0, width: 800, height: 100),
                                      @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FloatingPanelModifier(isPresented: isPresented, contentRect: contentRect, view: content))
    }
}

struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var contentRect: CGRect
    @ViewBuilder let view: () -> PanelContent
    @State var panel: FloatingPanel<PanelContent>?
 
    func body(content: Content) -> some View {
        content
            .onAppear {
                panel = FloatingPanel(view: view, contentRect: contentRect, isPresented: $isPresented)
                panel?.restoreSavedPosition()
                if isPresented {
                    present()
                }
            }.onDisappear {
                panel?.close()
                panel = nil
            }.onChange(of: isPresented) {
                if isPresented {
                    panel?.orderFront(nil)
                    panel?.fadeIn()
                } else {
                    panel?.fadeOut()
                }
            }
            .onChange(of: ViewModel.shared.userDefaultStorage.karaoke) {
                if !ViewModel.shared.userDefaultStorage.karaoke {
                    panel?.close()
                }
            }
    }
 
    func present() {
        panel?.orderFront(nil)
        panel?.fadeIn()
    }
}

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}
 
extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}

class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    private let savedFrameOriginKey = "karaokeWindowFrameOrigin"
    private var isSnappedToCenter: Bool = false
    private let snapThreshold: CGFloat = 25.0
    private var dragStartMouseLocation: NSPoint?
    private var dragStartWindowOrigin: NSPoint?

    init(view: () -> Content,
             contentRect: NSRect,
             backing: NSWindow.BackingStoreType = .buffered,
             defer flag: Bool = false,
             isPresented: Binding<Bool>) {
        self._isPresented = isPresented
     
        super.init(contentRect: contentRect,
                   styleMask: [.nonactivatingPanel, .fullSizeContentView, .closable],
                   backing: .buffered,
                   defer: true)
     
        isFloatingPanel = true
        level = .mainMenu
     
        collectionBehavior.insert(.canJoinAllSpaces)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
        backgroundColor = NSColor.clear
        isOpaque = false
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
//        let glassview = NSGlassEffectView()
//        appearance = NSAppearance(named: .darkAqua)
        let hostingview = NSHostingView(rootView: view()
            .preferredColorScheme(.dark)
            .environment(\.floatingPanel, self))
//        glassview.translatesAutoresizingMaskIntoConstraints = false
//        hostingview.translatesAutoresizingMaskIntoConstraints = false
//        glassview.contentView = hostingview
//        contentView = glassview
        contentView = hostingview
        hasShadow = false
    }
    
    override func resignMain() {
        super.resignMain()
    }
    
    func fadeIn() {
        self.alphaValue = 0.0
        self.animator().alphaValue = 1.0
    }
    
    func fadeOut() {
        NSAnimationContext.runAnimationGroup { animation in
            animation.duration = 0.1
            self.animator().alphaValue = 0.0
        }
    }
    
     
    override func close() {
        saveFrameOrigin()
        NSAnimationContext.runAnimationGroup { animation in
            animation.completionHandler = {
                super.close()
            }
            self.animator().alphaValue = 0.0
        }
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    override func center() {
        guard let screen = self.screen ?? NSScreen.main ?? NSScreen.screens.first else { return }
        let visibleFrame = screen.visibleFrame
        setFrameOrigin(NSPoint(
            x: visibleFrame.minX + max(0, (visibleFrame.width - frame.width) / 2),
            y: visibleFrame.minY + max(0, (visibleFrame.height - frame.height) / 5)
        ))
    }

    func restoreSavedPosition() {
        if let savedOrigin = UserDefaults.standard.dictionary(forKey: savedFrameOriginKey),
           let x = savedOrigin["x"] as? Double,
           let y = savedOrigin["y"] as? Double,
           x.isFinite, y.isFinite {
            let savedFrame = NSRect(origin: NSPoint(x: x, y: y), size: frame.size)
            if NSScreen.screens.contains(where: { $0.visibleFrame.contains(savedFrame) }) {
                setFrameOrigin(savedFrame.origin)
                return
            }
        }
        center()
        saveFrameOrigin()
    }

    private func saveFrameOrigin() {
        UserDefaults.standard.set([
            "x": Double(frame.origin.x),
            "y": Double(frame.origin.y)
        ], forKey: savedFrameOriginKey)
    }

    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            dragStartMouseLocation = NSEvent.mouseLocation
            dragStartWindowOrigin = self.frame.origin
            super.sendEvent(event)
        case .leftMouseDragged:
            guard let startMouse = dragStartMouseLocation,
                  let startOrigin = dragStartWindowOrigin else {
                super.sendEvent(event)
                return
            }
            let currentMouse = NSEvent.mouseLocation
            let deltaX = currentMouse.x - startMouse.x
            let deltaY = currentMouse.y - startMouse.y
            var newOrigin = NSPoint(x: startOrigin.x + deltaX, y: startOrigin.y + deltaY)

            if let screenFrame = (self.screen ?? NSScreen.main)?.frame {
                let windowCenterX = newOrigin.x + self.frame.width / 2
                let distanceFromCenter = abs(windowCenterX - screenFrame.midX)
                if distanceFromCenter <= snapThreshold {
                    let snappedOriginX = screenFrame.minX + (screenFrame.width - self.frame.width) / 2
                    if !isSnappedToCenter {
                        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                        isSnappedToCenter = true
                    }
                    newOrigin.x = snappedOriginX
                } else {
                    isSnappedToCenter = false
                }
            }

            self.setFrameOrigin(newOrigin)
            // Don't call super — AppKit would otherwise also try to move the window
        case .leftMouseUp:
            saveFrameOrigin()
            dragStartMouseLocation = nil
            dragStartWindowOrigin = nil
            isSnappedToCenter = false
            super.sendEvent(event)
        default:
            super.sendEvent(event)
        }
    }
}
