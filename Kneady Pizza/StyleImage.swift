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
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .accessibilityLabel("\(style.name) pizza")
                .id(style.id)
                .transition(.opacity)
        }
    }
}
