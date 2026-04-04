import UIKit

/// Custom drawn VoiceIt logo using bezier paths
@objc(VoiceItLogo)
public class SwiftVoiceItLogo: UIView {

    public override func draw(_ rect: CGRect) {
        let c = Theme.iconUIColor
        drawPath(c, points: [(18.48,96.21),(71.43,22.64),(71.09,-0.27),(0.81,96.21)], closed: true)
        drawPath(c, points: [(44,96.21),(96.95,22.64),(96.61,-0.27),(26.33,96.21)], closed: false)

        let p3 = UIBezierPath()
        p3.move(to: p(43.62,99.7)); p3.addLine(to: p(96.57,173.27)); p3.addLine(to: p(96.23,196.18)); p3.addLine(to: p(25.95,99.7)); p3.close()
        p3.move(to: p(18.1,99.7)); p3.addLine(to: p(71.05,173.27)); p3.addLine(to: p(70.71,196.18)); p3.addLine(to: p(0.43,99.7)); p3.close()
        p3.usesEvenOddFillRule = true; c.setFill(); p3.fill()

        drawPath(c, points: [(152.64,96.3),(99.46,22.69),(99.81,-0.23),(170.38,96.3)], closed: true)
        drawPath(c, points: [(127.01,96.3),(73.84,22.69),(74.18,-0.23),(144.76,96.3)], closed: false)

        let p6 = UIBezierPath()
        p6.move(to: p(127.4,99.79)); p6.addLine(to: p(74.22,173.41)); p6.addLine(to: p(74.56,196.33)); p6.addLine(to: p(145.14,99.79)); p6.close()
        p6.move(to: p(153.02,99.79)); p6.addLine(to: p(99.84,173.41)); p6.addLine(to: p(100.19,196.33)); p6.addLine(to: p(170.77,99.79)); p6.close()
        p6.usesEvenOddFillRule = true; c.setFill(); p6.fill()

        // Center globe
        let g = UIBezierPath()
        g.move(to: p(107.93,100.3))
        g.addCurve(to: p(107.76,102.58), controlPoint1: p(107.89,101.07), controlPoint2: p(107.83,101.83))
        g.addLine(to: p(98.86,102.58)); g.addLine(to: p(98.86,107.15)); g.addLine(to: p(107.08,107.15))
        g.addCurve(to: p(106.56,109.44), controlPoint1: p(106.93,107.93), controlPoint2: p(106.75,108.69))
        g.addLine(to: p(98.86,109.44)); g.addLine(to: p(98.86,114)); g.addLine(to: p(105.08,114))
        g.addCurve(to: p(86.32,129.99), controlPoint1: p(101.34,123.56), controlPoint2: p(94.34,129.99))
        g.addCurve(to: p(67.55,114), controlPoint1: p(78.3,129.99), controlPoint2: p(71.3,123.56))
        g.addLine(to: p(74.54,114)); g.addLine(to: p(74.54,109.44)); g.addLine(to: p(66.08,109.44))
        g.addCurve(to: p(65.55,107.15), controlPoint1: p(65.88,108.69), controlPoint2: p(65.71,107.93))
        g.addLine(to: p(74.54,107.15)); g.addLine(to: p(74.54,102.58)); g.addLine(to: p(64.88,102.58))
        g.addCurve(to: p(64.71,100.3), controlPoint1: p(64.8,101.83), controlPoint2: p(64.75,101.07))
        g.addLine(to: p(74.54,100.3)); g.addLine(to: p(74.54,95.73)); g.addLine(to: p(64.71,95.73))
        g.addCurve(to: p(86.32,66.05), controlPoint1: p(65.5,79.14), controlPoint2: p(74.88,66.05))
        g.addCurve(to: p(107.93,95.73), controlPoint1: p(97.76,66.05), controlPoint2: p(107.13,79.14))
        g.addLine(to: p(98.86,95.73)); g.addLine(to: p(98.86,100.3)); g.addLine(to: p(107.93,100.3))
        g.close()
        g.usesEvenOddFillRule = true; c.setFill(); g.fill()
    }

    private func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

    private func drawPath(_ color: UIColor, points: [(CGFloat,CGFloat)], closed: Bool) {
        let path = UIBezierPath()
        for (i, pt) in points.enumerated() {
            if i == 0 { path.move(to: p(pt.0, pt.1)) }
            else { path.addLine(to: p(pt.0, pt.1)) }
        }
        if closed { path.close() }
        path.usesEvenOddFillRule = true
        color.setFill()
        path.fill()
    }
}
