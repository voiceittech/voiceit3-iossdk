import UIKit

/// Animated loading spinner using CAShapeLayer stroke animation
@objc(SpinningView)
public class SwiftSpinningView: UIView, CAAnimationDelegate {

    @objc public var circleLayer = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup() {
        circleLayer.lineWidth = 8
        circleLayer.fillColor = nil
        circleLayer.strokeColor = Theme.mainCGColor
        layer.addSublayer(circleLayer)
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag { startAnimation() }
    }

    @objc public func startAnimation() {
        let inAnim = CABasicAnimation(keyPath: "strokeEnd")
        inAnim.fromValue = 0.0
        inAnim.toValue = 1.0
        inAnim.duration = 2.0
        inAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let outAnim = CABasicAnimation(keyPath: "strokeStart")
        outAnim.beginTime = 1.0
        outAnim.fromValue = 0.0
        outAnim.toValue = 1.0
        outAnim.duration = 2.0
        outAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

        circleLayer.removeAnimation(forKey: "strokeAnimation")
        let group = CAAnimationGroup()
        group.duration = 2.0 + outAnim.beginTime
        group.repeatCount = .greatestFiniteMagnitude
        group.animations = [inAnim, outAnim]
        group.delegate = self
        circleLayer.add(group, forKey: "strokeAnimation")
    }

    @objc public func endAnimation() {
        circleLayer.removeAllAnimations()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let yPoint = frame.size.height * 0.75
        let center = CGPoint(x: self.center.x, y: yPoint)
        let radius = 75.0 / 2 - circleLayer.lineWidth / 2
        let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: .pi / 2, endAngle: .pi / 2 + .pi * 2, clockwise: true)
        circleLayer.position = center
        circleLayer.path = path.cgPath
        startAnimation()

        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = 2 * CGFloat.pi
        rotation.duration = 4.0
        rotation.repeatCount = .greatestFiniteMagnitude
        circleLayer.add(rotation, forKey: "rotateAnimation")
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}
