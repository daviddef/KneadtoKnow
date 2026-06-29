import SwiftUI
import AVFoundation

/// A silent, auto-looping inline video (no controls) for animated Kid Mode steps.
struct VideoLoopView: UIViewRepresentable {
    let resource: String   // bundled .mp4 base name (no extension)

    func makeUIView(context: Context) -> LoopingPlayerUIView { LoopingPlayerUIView(resource: resource) }
    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {}

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

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    deinit { queue?.pause() }
}
