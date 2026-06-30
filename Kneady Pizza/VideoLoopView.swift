import SwiftUI
import AVFoundation

/// An auto-looping inline video with a mute/unmute button. Mute is driven by a
/// shared binding (so one button controls every clip), and the video only plays
/// while it's the active page — otherwise it pauses on the current frame.
struct KidVideo: View {
    let resource: String
    @Binding var muted: Bool
    var isActive: Bool = true

    var body: some View {
        VideoLoopView(resource: resource, muted: muted, isActive: isActive)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    Haptics.tap()
                    muted.toggle()
                    if !muted { KidAudio.activate() }
                } label: {
                    Image(systemName: muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.rounded(16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.black.opacity(0.45)))
                }
                .buttonStyle(.plain)
                .padding(10)
            }
    }
}

/// Audio session helper — switch to playback so unmuted clips are heard even
/// when the ring/silent switch is on.
enum KidAudio {
    static func activate() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers])
        try? session.setActive(true)
    }
}

struct VideoLoopView: UIViewRepresentable {
    let resource: String
    var muted: Bool = true
    var isActive: Bool = true

    func makeUIView(context: Context) -> LoopingPlayerUIView { LoopingPlayerUIView(resource: resource) }
    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {
        uiView.setMuted(muted)
        uiView.setActive(isActive)
    }

    /// Whether the clip exists in the bundle — so the caller can fall back.
    static func exists(_ resource: String) -> Bool {
        Bundle.main.url(forResource: resource, withExtension: "mp4") != nil
    }
}

final class LoopingPlayerUIView: UIView {
    private var player: AVPlayer?
    private let playerLayer = AVPlayerLayer()
    private var active = true
    private var endObserver: NSObjectProtocol?
    private var restartWork: DispatchWorkItem?

    /// Seconds to hold on the last frame before looping again.
    private let loopGap: TimeInterval = 15

    init(resource: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp4") else { return }
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.isMuted = true
        p.actionAtItemEnd = .pause   // hold the last frame; we restart after a gap
        playerLayer.player = p
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        player = p
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in self?.scheduleRestart() }
        p.play()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func scheduleRestart() {
        restartWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.active else { return }
            self.player?.seek(to: .zero)
            self.player?.play()
        }
        restartWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + loopGap, execute: work)
    }

    func setMuted(_ muted: Bool) { player?.isMuted = muted }

    /// Play only the active page; pause (freeze the frame) otherwise.
    func setActive(_ isActive: Bool) {
        guard isActive != active else { return }
        active = isActive
        if isActive {
            // If it had finished, restart from the top; otherwise resume.
            if let item = player?.currentItem, item.duration.seconds.isFinite,
               item.currentTime().seconds >= item.duration.seconds - 0.1 {
                player?.seek(to: .zero)
            }
            player?.play()
        } else {
            player?.pause()
            restartWork?.cancel()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    deinit {
        player?.pause()
        restartWork?.cancel()
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
    }
}
