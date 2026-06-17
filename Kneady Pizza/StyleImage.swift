import SwiftUI

/// Loads bundled images by name, whether they live in the asset catalog or as
/// loose PNG files dropped into the app folder.
enum AppImages {
    static func named(_ name: String) -> UIImage? {
        if let img = UIImage(named: name) { return img }
        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let img = UIImage(contentsOfFile: url.path) {
            return img
        }
        return nil
    }
}

/// The per-style hero image shown below the directions. Renders nothing until
/// the matching `hero-<id>.png` is present, so it degrades gracefully.
struct StyleHeroImage: View {
    let style: PizzaStyle

    var body: some View {
        if let img = AppImages.named(style.heroImageName) {
            let picture = Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

            Group {
                if Palette.isVibrant {
                    // Sticker / fridge-magnet look: white mount, soft shadow, a
                    // playful tilt.
                    picture
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                        )
                        .shadow(color: Palette.shadowDark.opacity(0.7), radius: 12, x: 0, y: 8)
                        .rotationEffect(.degrees(-2))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                } else {
                    picture
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .accessibilityLabel("\(style.name) pizza")
            .id(style.id)
            .transition(.opacity)
        }
    }
}
