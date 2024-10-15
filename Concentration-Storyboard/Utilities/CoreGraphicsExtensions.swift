import UIKit

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    var angleToOrigin : CGFloat {
        return atan2(self.y, self.x)
    }
    var distanceToOrigin : CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
}

extension CGFloat {
    
    var abs:CGFloat {
        Swift.abs(self)
    }
    var zeroIfNan:CGFloat {
        if self.isNaN {
            return 0
        } else {
            return self
        }
    }
    func roundToNearestStep(step: CGFloat, roundedValueToRealValueFactor:CGFloat = 0) -> CGFloat {
        let roundedValue = (self / step).rounded(.toNearestOrEven) * step
        let difference = roundedValue - self
        return roundedValue - (difference * roundedValueToRealValueFactor)
    }
    static var pi:CGFloat {
        CGFloat(Float.pi)
    }
}

extension CGRect {
    func zoom(by ratio:CGFloat) -> CGRect {
        return insetBy(dx: height*(1-ratio)/2, dy: width*(1-ratio)/2)
    }
}

func angleDifference(_ angle1: CGFloat, _ angle2: CGFloat) -> CGFloat {
    var difference = angle1 - angle2
    
    // Use modulo to wrap the result to the range between -π to π
    difference = (difference + CGFloat.pi).truncatingRemainder(dividingBy: 2 * CGFloat.pi) - CGFloat.pi
    
    return difference
}

extension CGSize {
    static func /(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
    var maxPoint : CGPoint {
        return CGPoint(x: self.width, y: self.height)
    }
}

extension CGAffineTransform {
    static func transform(view:UIView, toLookLike target:CGRect, fromView:UIView? = nil) -> CGAffineTransform {
        let realOrigin = view.frame.origin
        let realSize = view.frame.size
        let targetSize = target.size
        let targetOrigin : CGPoint
        if let superview = view.superview, let fromView {
            targetOrigin = superview.convert(target.origin, from: fromView)
        } else {
            targetOrigin = target.origin
        }
                
        
        let targetOriginTranslation = targetOrigin - realOrigin
        let targetSizeToRealSize = targetSize / realSize
        let targetSizeToRealSizeTranslation = (targetSize - realSize) / 2
        
        let targetAffineTransform = {
            CGAffineTransform.identity
                .translatedBy(x: targetOriginTranslation.x, y: targetOriginTranslation.y)
                .translatedBy(x: targetSizeToRealSizeTranslation.width, y: targetSizeToRealSizeTranslation.height)
                .scaledBy(x: targetSizeToRealSize.width, y: targetSizeToRealSize.height)
        }()
        
        return targetAffineTransform
    }
}
