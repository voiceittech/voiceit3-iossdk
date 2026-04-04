import UIKit

/// Siri-style waveform visualization for audio recording feedback
@objc(SCSiriWaveformView)
public class WaveformView: UIView {

    @objc public var numberOfWaves: Int = 2
    @objc public var waveColor: UIColor = .yellow
    @objc public var primaryWaveLineWidth: CGFloat = 3.0
    @objc public var secondaryWaveLineWidth: CGFloat = 3.0
    @objc public var idleAmplitude: CGFloat = 0.0
    @objc public var frequency: CGFloat = 6.0
    @objc public private(set) var amplitude: CGFloat = 0.5
    @objc public var density: CGFloat = 5.0
    @objc public var phaseShift: CGFloat = -0.15

    private var phase: CGFloat = 0

    @objc public func update(withLevel level: CGFloat) {
        phase += phaseShift
        amplitude = max(level, idleAmplitude)
        setNeedsDisplay()
    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(bounds)
        backgroundColor?.set()
        context.fill(rect)

        for i in 0..<numberOfWaves {
            let strokeWidth = (i == 0) ? primaryWaveLineWidth : secondaryWaveLineWidth
            context.setLineWidth(strokeWidth)

            let halfHeight = bounds.height / 2.0
            let width = bounds.width
            let mid = width / 2.0
            let maxAmplitude = halfHeight - (strokeWidth * 2)

            let progress = 1.0 - CGFloat(i) / CGFloat(numberOfWaves)
            let normedAmplitude = (1.5 * progress - (2.0 / CGFloat(numberOfWaves))) * amplitude

            let multiplier = min(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0))
            waveColor.withAlphaComponent(multiplier * waveColor.cgColor.alpha).set()

            var x: CGFloat = 0
            while x < (width + density) {
                let scaling = -pow(1 / mid * (x - mid), 2) + 1
                let y = scaling * maxAmplitude * normedAmplitude * sin(2 * .pi * (x / width) * frequency + phase) + halfHeight
                if x == 0 { context.move(to: CGPoint(x: x, y: y)) }
                else { context.addLine(to: CGPoint(x: x, y: y)) }
                x += density
            }
            context.strokePath()
        }
    }
}
