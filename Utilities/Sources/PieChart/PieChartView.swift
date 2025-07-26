import Foundation
import UIKit

public struct Entity {
    public let value: Decimal
    public let label: String
    
    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

extension Decimal {
    func asNumber() -> NSNumber {
        return NSDecimalNumber(decimal: self)
    }
}

public class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet { setNeedsDisplay() }
    }

    private let colors: [UIColor] = [
        UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0), // Зеленый
        UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0), // Желтый
        UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0), // Голубой
        UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0), // Красный
        UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0), // Фиолетовый
        UIColor(red: 0.8, green: 0.8, blue: 0.2, alpha: 1.0)  // Оливковый
    ]

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.7 // Expanded center circle
        var startAngle: CGFloat = 0

        let total = entities.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        // Draw the background to match the screen
        UIColor(white: 0.95, alpha: 1.0).setFill() // Light gray background
        UIRectFill(rect)

        for (index, entity) in entities.enumerated() {
            let valueRatio = entity.value / total
            let angleIncrement = CGFloat(truncating: valueRatio as NSNumber) * 2 * .pi
            let endAngle = startAngle + angleIncrement

            // Draw the thinner segment around the center
            let segmentWidth: CGFloat = (outerRadius - innerRadius) * 0.2 // Thinner line
            let segmentOuterRadius = innerRadius + segmentWidth
            let path = UIBezierPath()
            path.move(to: CGPoint(x: center.x + innerRadius * cos(startAngle), y: center.y + innerRadius * sin(startAngle)))
            path.addArc(withCenter: center, radius: segmentOuterRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()
            colors[index % colors.count].setFill()
            path.fill()

            startAngle = endAngle
        }

        // Add entity's label with color circle and black text pinned to the left with wrapping
        let labelFont = UIFont.systemFont(ofSize: 8)
        let circleSize: CGFloat = 10
        let baseX: CGFloat = center.x - innerRadius * 0.5 // Left edge of the circle
        let maxWidth = innerRadius * 1.8 - circleSize - 10 // Available width for text
        var currentY: CGFloat = center.y - (CGFloat(entities.count) * 15) / 2 // Vertical centering with reduced spacing

        for (index, entity) in entities.enumerated() {
            let valueRatio = entity.value / total
            let percentage = Int((valueRatio * 100).asNumber().doubleValue)
            let legendText = "\(percentage)% \(entity.label)"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left

            let legendTextAttributes: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]

            let attributedString = NSAttributedString(string: legendText, attributes: legendTextAttributes)
            let textRect = CGRect(x: baseX + circleSize + 5, y: currentY, width: maxWidth, height: .greatestFiniteMagnitude)
            attributedString.draw(with: textRect, options: .usesLineFragmentOrigin, context: nil)

            // Draw colored circle
            let circlePath = UIBezierPath(ovalIn: CGRect(x: baseX, y: currentY, width: circleSize, height: circleSize))
            colors[index % colors.count].setFill()
            circlePath.fill()

            // Adjust currentY based on the height of the drawn text
            let textHeight = attributedString.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
            currentY += max(textHeight, CGFloat(15)) // Ensure at least 15 points spacing

        }
    }
}
