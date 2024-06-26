import SwiftUI

// Credit: https://gist.github.com/liorazi/689047404b4508f94262ee6f946b97fd

public extension Animation {
    static func easeInSin(duration: Double) -> Animation {
        return self.timingCurve(0.47, 0, 0.745, 0.715, duration: duration)
    }

    static var easeInSin: Animation = .timingCurve(0.47, 0, 0.745, 0.715)

    static func easeOutSin(duration: Double) -> Animation {
        return self.timingCurve(0.39, 0.575, 0.565, 1, duration: duration)
    }

    static var easeOutSin: Animation = .timingCurve(0.39, 0.575, 0.565, 1)

    static func easeInOutSine(duration: Double) -> Animation {
        return self.timingCurve(0.445, 0.05, 0.55, 0.95, duration: duration)
    }

    static var easeInOutSine: Animation = .timingCurve(0.445, 0.05, 0.55, 0.95)

    static func easeInQuad(duration: Double) -> Animation {
        return self.timingCurve(0.55, 0.085, 0.68, 0.53, duration: duration)
    }

    static var easeInQuad: Animation = .timingCurve(0.55, 0.085, 0.68, 0.53)

    static func easeOutQuad(duration: Double) -> Animation {
        return self.timingCurve(0.25, 0.46, 0.45, 0.94, duration: duration)
    }

    static var easeOutQuad: Animation = .timingCurve(0.25, 0.46, 0.45, 0.94)

    static func easeInOutQuad(duration: Double) -> Animation {
        return self.timingCurve(0.455, 0.03, 0.515, 0.955, duration: duration)
    }

    static var easeInOutQuad: Animation = .timingCurve(0.455, 0.03, 0.515, 0.955)

    static func easeInCubic(duration: Double) -> Animation {
        return self.timingCurve(0.55, 0.055, 0.675, 0.19, duration: duration)
    }

    static var easeInCubic: Animation = .timingCurve(0.55, 0.055, 0.675, 0.19)

    static func easeOutCubic(duration: Double) -> Animation {
        return self.timingCurve(0.215, 0.61, 0.355, 1, duration: duration)
    }

    static var easeOutCubic: Animation = .timingCurve(0.215, 0.61, 0.355, 1)

    static func easeInQuart(duration: Double) -> Animation {
        return self.timingCurve(0.895, 0.03, 0.685, 0.22, duration: duration)
    }

    static var easeInQuart: Animation = .timingCurve(0.895, 0.03, 0.685, 0.22)

    static func easeOutQuart(duration: Double) -> Animation {
        return self.timingCurve(0.165, 0.84, 0.44, 1, duration: duration)
    }

    static var easeOutQuart: Animation = .timingCurve(0.165, 0.84, 0.44, 1)

    static func easeInOutQuart(duration: Double) -> Animation {
        return self.timingCurve(0.77, 0, 0.175, 1, duration: duration)
    }

    static var easeInOutQuart: Animation = .timingCurve(0.77, 0, 0.175, 1)

    static func easeInQuint(duration: Double) -> Animation {
        return self.timingCurve(0.755, 0.05, 0.855, 0.06, duration: duration)
    }

    static var easeInQuint: Animation = .timingCurve(0.755, 0.05, 0.855, 0.06)

    static func easeOutQuint(duration: Double) -> Animation {
        return self.timingCurve(0.23, 1, 0.32, 1, duration: duration)
    }

    static var easeOutQuint: Animation = .timingCurve(0.23, 1, 0.32, 1)

    static func easeInOutQuint(duration: Double) -> Animation {
        return self.timingCurve(0.86, 0, 0.07, 1, duration: duration)
    }

    static var easeInOutQuint: Animation = .timingCurve(0.86, 0, 0.07, 1)

    static func easeInExpo(duration: Double) -> Animation {
        return self.timingCurve(0.95, 0.05, 0.795, 0.035, duration: duration)
    }

    static var easeInExpo: Animation = .timingCurve(0.95, 0.05, 0.795, 0.035)

    static func easeOutExpo(duration: Double) -> Animation {
        return self.timingCurve(0.19, 1, 0.22, 1, duration: duration)
    }

    static var easeOutExpo: Animation = .timingCurve(0.19, 1, 0.22, 1)

    static func easeInOutExpo(duration: Double) -> Animation {
        return self.timingCurve(1, 0, 0, 1, duration: duration)
    }

    static var easeInOutExpo: Animation = .timingCurve(1, 0, 0, 1)

    static func easeInCirc(duration: Double) -> Animation {
        return self.timingCurve(0.6, 0.04, 0.98, 0.335, duration: duration)
    }

    static var easeInCirc: Animation = .timingCurve(0.6, 0.04, 0.98, 0.335)

    static func easeOutCirc(duration: Double) -> Animation {
        return self.timingCurve(0.075, 0.82, 0.165, 1, duration: duration)
    }

    static var easeOutCirc: Animation = .timingCurve(0.075, 0.82, 0.165, 1)

    static func easeInOutCirc(duration: Double) -> Animation {
        return self.timingCurve(0.785, 0.135, 0.15, 0.86, duration: duration)
    }

    static var easeInOutCirc: Animation = .timingCurve(0.785, 0.135, 0.15, 0.86)

    static func easeInBack(duration: Double) -> Animation {
        return self.timingCurve(0.6, -0.28, 0.735, 0.045, duration: duration)
    }

    static var easeInBack: Animation = .timingCurve(0.6, -0.28, 0.735, 0.045)

    static func easeOutBack(duration: Double) -> Animation {
        return self.timingCurve(0.175, 0.885, 0.32, 1.275, duration: duration)
    }

    static var easeOutBack: Animation = .timingCurve(0.175, 0.885, 0.32, 1.275)

    static func easeInOutBack(duration: Double) -> Animation {
        return self.timingCurve(0.68, -0.55, 0.265, 1.55, duration: duration)
    }

    static var easeInOutBack: Animation = .timingCurve(0.68, -0.55, 0.265, 1.55)
}
