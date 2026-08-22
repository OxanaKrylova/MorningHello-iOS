//
//  PostcardRenderer..swift
//  MorningHello
//
//  Created by Oxana Krylova on 05/08/2026.
//

import UIKit

struct PostcardRenderInput {
    let imageName: String
    let baseText: String
    let customText: String?
}

struct PostcardRenderer {

    func render(input: PostcardRenderInput) -> UIImage? {
        guard let baseImage = UIImage(named: input.imageName) else {
            return nil
        }

        let size = baseImage.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            let fullRect = CGRect(origin: .zero, size: size)

            // 1. Фон
            baseImage.draw(in: fullRect)

            // 2. Верхнее мягкое затемнение
            if let gradient = makeTopGradient(size: size) {
                gradient.draw(
                    in: CGRect(
                        x: 0,
                        y: 0,
                        width: size.width,
                        height: size.height * 0.42
                    )
                )
            }

            let horizontalInset: CGFloat = size.width * 0.20

            // 3. Базовый текст
            let trimmedBaseText = input.baseText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            if !trimmedBaseText.isEmpty {

                let baseTextRect = CGRect(
                    x: horizontalInset,
                    y: size.height * 0.11,
                    width: size.width - horizontalInset * 2,
                    height: size.height * 0.22
                )

                drawTextBubble(
                    text: trimmedBaseText,
                    in: baseTextRect,
                    font: UIFont.systemFont(
                        ofSize: size.width * 0.055,
                        weight: .semibold
                    ),
                    textColor: .white,
                    bubbleColor: UIColor.black.withAlphaComponent(0.24)
                )
            }

            // 4. Пользовательский текст
            let trimmedCustomText = input.customText?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if let customText = trimmedCustomText,
               !customText.isEmpty {

                let customTextRect = CGRect(
                    x: horizontalInset,
                    y: size.height * 0.70,
                    width: size.width - horizontalInset * 2,
                    height: size.height * 0.15
                )

                drawTextBubble(
                    text: customText,
                    in: customTextRect,
                    font: UIFont.italicSystemFont(
                        ofSize: size.width * 0.05
                    ),
                    textColor: .white,
                    bubbleColor: UIColor.black.withAlphaComponent(0.28)
                )
            }
        }
    }

    private func makeTopGradient(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: size.width,
                height: size.height * 0.42
            )
        )

        return renderer.image { context in
            let colors = [
                UIColor.black.withAlphaComponent(0.45).cgColor,
                UIColor.clear.cgColor
            ] as CFArray

            let colorSpace = CGColorSpaceCreateDeviceRGB()

            guard let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors,
                locations: [0.0, 1.0]
            ) else {
                return
            }

            let start = CGPoint(x: size.width / 2, y: 0)
            let end = CGPoint(x: size.width / 2, y: size.height * 0.42)

            context.cgContext.drawLinearGradient(
                gradient,
                start: start,
                end: end,
                options: []
            )
        }
    }

    private func drawTextBubble(
        text: String,
        in rect: CGRect,
        font: UIFont,
        textColor: UIColor,
        bubbleColor: UIColor
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let paddedRect = rect.insetBy(dx: 18, dy: 14)

        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(
                width: paddedRect.width,
                height: .greatestFiniteMagnitude
            ),
            options: [
                .usesLineFragmentOrigin,
                .usesFontLeading
            ],
            attributes: attributes,
            context: nil
        )

        let bubbleHeight = max(
            boundingRect.height + 28,
            60
        )

        let bubbleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: bubbleHeight
        )

        let bubblePath = UIBezierPath(
            roundedRect: bubbleRect,
            cornerRadius: 18
        )

        bubbleColor.setFill()
        bubblePath.fill()

        let drawRect = CGRect(
            x: bubbleRect.minX + 18,
            y: bubbleRect.minY + 14,
            width: bubbleRect.width - 36,
            height: bubbleRect.height - 28
        )

        (text as NSString).draw(
            with: drawRect,
            options: [
                .usesLineFragmentOrigin,
                .usesFontLeading
            ],
            attributes: attributes,
            context: nil
        )
    }
}
