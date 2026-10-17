import SwiftUI

/// The plate of rice, grilled chicken and greens used across the mocks.
///
/// Drawn on a 240 × 240 grid and scaled to the space it gets; it keeps a 1:1 aspect ratio.
/// Decorative, so it is hidden from VoiceOver.
public struct PlateIllustration: View {

    public init() {}

    public var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let scale = side / 240
            context.translateBy(x: (size.width - side) / 2, y: (size.height - side) / 2)
            context.scaleBy(x: scale, y: scale)

            // Plate
            context.fill(Self.circle(x: 120, y: 120, radius: 118), with: .color(PratoColor.plateRim))
            context.fill(Self.circle(x: 120, y: 120, radius: 98), with: .color(PratoColor.plate))

            // Rice
            context.fill(
                Path(ellipseIn: CGRect(x: 46, y: 46, width: 84, height: 88)),
                with: .color(Self.rice)
            )
            var grains = Path()
            for (start, end) in Self.riceGrains {
                grains.move(to: start)
                grains.addLine(to: end)
            }
            context.stroke(grains, with: .color(Self.riceGrain), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))

            // Grilled chicken
            context.fill(
                Path(roundedRect: CGRect(x: 138, y: 52, width: 60, height: 108), cornerRadius: 30),
                with: .color(Self.chicken)
            )
            var grillMarks = Path()
            for y in stride(from: 72.0, through: 132.0, by: 20.0) {
                grillMarks.move(to: CGPoint(x: 150, y: y))
                grillMarks.addLine(to: CGPoint(x: 186, y: y + 7))
            }
            context.stroke(grillMarks, with: .color(Self.grill), style: StrokeStyle(lineWidth: 4, lineCap: .round))

            // Greens
            for leaf in Self.leaves {
                context.fill(Self.circle(x: leaf.x, y: leaf.y, radius: leaf.radius), with: .color(leaf.color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private nonisolated static func circle(x: CGFloat, y: CGFloat, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
    }

    // Food colors stay the same in light and dark: food should not change color with the theme.
    private nonisolated static let rice = Color(rgb: 0xF1E4C6)
    private nonisolated static let riceGrain = Color(rgb: 0xE2D2AC)
    private nonisolated static let chicken = Color(rgb: 0xC98B4B)
    private nonisolated static let grill = Color(rgb: 0x8F5428)
    private nonisolated static let darkLeaf = Color(rgb: 0x4E8239)
    private nonisolated static let midLeaf = Color(rgb: 0x6C9A48)
    private nonisolated static let lightLeaf = Color(rgb: 0x8AAA5E)

    private nonisolated static let riceGrains: [(CGPoint, CGPoint)] = [
        (CGPoint(x: 70, y: 70), CGPoint(x: 74, y: 79)),
        (CGPoint(x: 84, y: 64), CGPoint(x: 87, y: 72)),
        (CGPoint(x: 98, y: 72), CGPoint(x: 102, y: 82)),
        (CGPoint(x: 76, y: 92), CGPoint(x: 79, y: 100)),
        (CGPoint(x: 92, y: 96), CGPoint(x: 96, y: 105)),
        (CGPoint(x: 106, y: 88), CGPoint(x: 109, y: 96)),
        (CGPoint(x: 80, y: 112), CGPoint(x: 84, y: 120)),
        (CGPoint(x: 96, y: 116), CGPoint(x: 99, y: 123))
    ]

    private struct Leaf {
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let color: Color
    }

    private nonisolated static let leaves: [Leaf] = [
        Leaf(x: 64, y: 150, radius: 9, color: lightLeaf),
        Leaf(x: 82, y: 146, radius: 11, color: darkLeaf),
        Leaf(x: 102, y: 148, radius: 10, color: darkLeaf),
        Leaf(x: 120, y: 150, radius: 9, color: midLeaf),
        Leaf(x: 74, y: 166, radius: 10, color: darkLeaf),
        Leaf(x: 96, y: 164, radius: 12, color: midLeaf),
        Leaf(x: 116, y: 168, radius: 10, color: lightLeaf),
        Leaf(x: 132, y: 160, radius: 9, color: darkLeaf),
        Leaf(x: 66, y: 182, radius: 10, color: darkLeaf),
        Leaf(x: 86, y: 184, radius: 11, color: midLeaf),
        Leaf(x: 108, y: 184, radius: 10, color: lightLeaf),
        Leaf(x: 128, y: 178, radius: 9, color: midLeaf)
    ]
}

#Preview {
    PlateIllustration()
        .frame(width: 240)
        .padding()
        .background(PratoColor.softSurface)
}
