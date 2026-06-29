import SwiftUI
import AVFoundation

/// A silent-by-default, auto-looping inline video with a mute/unmute button —
/// used for animated Kid Mode steps and the hero.
struct KidVideo: View {
    let resource: String
    @State private var muted = true

    var body: some View {
        VideoLoopView(resource: resource, muted: muted)
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

    func makeUIView(context: Context) -> LoopingPlayerUIView { LoopingPlayerUIView(resource: resource) }
    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) { uiView.setMuted(muted) }

    /// Whether the clip exists in the bundle — so the caller can fall back.
    static func exists(_ resource: String) -> Bool {
        Bundle.main.url(forResource: resource, withExtension: "mp4") != nil
    }
}

final class LoopingPlayerUIView: UIView {
    private var queue: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private let playerLayer = AVPlayerLayer()

    init(resource: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp4") else { return }
        let item = AVPlayerItem(url: url)
        let q = AVQueuePlayer()
        q.isMuted = true
        looper = AVPlayerLooper(player: q, templateItem: item)
        playerLayer.player = q
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        queue = q
        q.play()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setMuted(_ muted: Bool) { queue?.isMuted = muted }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    deinit { queue?.pause() }
}
