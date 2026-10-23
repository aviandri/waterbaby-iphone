import AVFoundation
import SwiftUI
import UIKit

/// The capybara cheering with its bottle while confetti bursts: a seamless, silent 5 s loop of
/// `goal-reached.mp4`. The clip's background was levelled to pure white, so show it on white.
/// With Reduce Motion on (or if the clip is missing) it shows the still hero art instead.
struct GoalReachedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let videoURL = Bundle.main.url(forResource: "goal-reached", withExtension: "mp4")

    var body: some View {
        Group {
            if !reduceMotion, let url = Self.videoURL {
                LoopingVideo(url: url)
            } else {
                Image("CapybaraHero")
                    .resizable()
                    .scaledToFit()
                    .padding(32)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(Color.white)
        .accessibilityElement()
        .accessibilityLabel("The capybara cheers with its bottle")
    }
}

/// Home's goal celebration: dims the screen and shows `GoalReachedView` on a white card with a
/// caption. Dismisses on tap anywhere, or by itself after `duration`.
struct GoalReachedOverlay: View {
    static let duration: Duration = .seconds(5)

    var onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.25 : 0)
                .ignoresSafeArea()
            VStack(spacing: 4) {
                GoalReachedView()
                    .frame(width: 280, height: 280)
                Text("Goal reached! 🎉")
                    .font(Theme.rounded(26))
                    .foregroundStyle(Theme.ink)
                    .padding(.bottom, 24)
            }
            .frame(width: 280)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onDismiss)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Dismisses the celebration")
        .task {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { appeared = true }
            try? await Task.sleep(for: Self.duration)
            guard !Task.isCancelled else { return }
            onDismiss()
        }
    }
}

/// A muted `AVQueuePlayer` + `AVPlayerLooper` drawn by an `AVPlayerLayer`, aspect-fit.
private struct LoopingVideo: UIViewRepresentable {
    let url: URL

    final class Coordinator {
        var looper: AVPlayerLooper?
    }

    final class PlayerView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.backgroundColor = .white
        let player = AVQueuePlayer()
        player.isMuted = true
        player.preventsDisplaySleepDuringVideoPlayback = false
        context.coordinator.looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        view.playerLayer.videoGravity = .resizeAspect
        view.playerLayer.player = player
        player.play()
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {}

    static func dismantleUIView(_ uiView: PlayerView, coordinator: Coordinator) {
        uiView.playerLayer.player?.pause()
        uiView.playerLayer.player = nil
        coordinator.looper?.disableLooping()
        coordinator.looper = nil
    }
}

#Preview("Loop") {
    GoalReachedView()
        .frame(width: 280, height: 280)
}

#Preview("Overlay") {
    ZStack {
        Color.white
        Text("Home")
        GoalReachedOverlay(onDismiss: {})
    }
}
