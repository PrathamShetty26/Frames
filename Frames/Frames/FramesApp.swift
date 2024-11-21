import SwiftUI
import AppKit

@main
struct FramesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear { configureWindow() }
        }
    }
    
    func configureWindow() {
        DispatchQueue.main.async {
            guard let window = NSApplication.shared.windows.first else { return }

            window.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.isOpaque = false
            window.backgroundColor = .clear
            setDefaultWindowSize(window: window)
            addTrafficLightBehavior(window: window)
        }
    }

    func setDefaultWindowSize(window: NSWindow) {
        guard let screenFrame = NSScreen.main?.visibleFrame else { return }
        let defaultWidth: CGFloat = screenFrame.width * 0.6
        let defaultHeight: CGFloat = defaultWidth * (9.0 / 16.0) // 16:9 ratio
        let xPosition = screenFrame.origin.x + (screenFrame.width - defaultWidth) / 2
        let yPosition = screenFrame.origin.y + (screenFrame.height - defaultHeight) / 2

        let frame = NSRect(x: xPosition, y: yPosition, width: defaultWidth, height: defaultHeight)
        window.setFrame(frame, display: true, animate: true)
    }

    func addTrafficLightBehavior(window: NSWindow) {
        let trackingArea = NSTrackingArea(
            rect: window.contentView?.frame ?? .zero,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
            owner: window,
            userInfo: nil
        )
        window.contentView?.addTrackingArea(trackingArea)
        toggleTrafficLights(window: window, visible: false)

        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
            guard let window = NSApplication.shared.windows.first else { return event }
            let location = event.locationInWindow
            let topThreshold: CGFloat = 50

            toggleTrafficLights(window: window, visible: location.y > (window.frame.size.height - topThreshold))
            return event
        }
    }

    func toggleTrafficLights(window: NSWindow, visible: Bool) {
        let alphaValue: CGFloat = visible ? 1.0 : 0.0
        let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            buttons.forEach { window.standardWindowButton($0)?.animator().alphaValue = alphaValue }
        }
    }
}
