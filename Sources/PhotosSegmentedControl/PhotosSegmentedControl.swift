#if canImport(UIKit) && canImport(SwiftUI)
import UIKit
import SwiftUI

public final class PhotosSegmentedControl: UIControl {
    
    public var items: [String] = [] {
        willSet {
            selectedItem = newValue.first
            labels = newValue.map { createLabel(for: $0) }
            setNeedsLayout()
        }
    }
    
    public var selectedItem: String? = nil {
        didSet {
            setNeedsLayout()
        }
    }

    private var labels: [UILabel] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private let visualEffectBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private let itemBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0.25
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(visualEffectBackground)
        addSubview(itemBackground)
        addSubview(contentStack)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let currentColorScheme = UITraitCollection.current.userInterfaceStyle
        itemBackground.effect = UIBlurEffect(style: invertedEffect(for: currentColorScheme))
        setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
                
        contentStack.frame.size.width = frame.width
        contentStack.frame.size.height = 40

        labels.forEach { contentStack.addArrangedSubview($0) }
        contentStack.layoutIfNeeded()
        
        visualEffectBackground.frame = contentStack.frame
        
        visualEffectBackground.clipsToBounds = true
        visualEffectBackground.layer.cornerRadius = visualEffectBackground.frame.height / 2
        
        guard let selectedItem = selectedItem else { return }
        updateItemBackground(for: selectedItem)
    }
    
    private func createLabel(for item: String) -> UILabel {
        let label = UILabel()
        label.text = item
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        return label
    }
    
    private func updateItemBackground(for item: String) {
        guard let selectedItem = labels.first(where: { $0.text == item }) else { return }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .curveEaseOut) { [weak self] in
            self?.itemBackground.frame = selectedItem.frame
        }
        
        itemBackground.clipsToBounds = true
        itemBackground.layer.cornerRadius = itemBackground.frame.height / 2
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateItem(from: touches, event: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        updateItem(from: touches, event: event)
    }
    
    private func updateItem(from touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: contentStack)
        let view = contentStack.hitTest(location, with: event)
        guard let item = labels.first(where: { $0 === view })?.text else { return }
        selectedItem = item
    }
        
    private func invertedEffect(for colorScheme: UIUserInterfaceStyle) -> UIBlurEffect.Style {
        switch colorScheme {
            case .light:
                return .systemMaterialDark
            case .dark:
                return .systemMaterialLight
            default:
                return .systemMaterial
        }
    }
    
}

struct PhotosSegmentedControlRepresentable: UIViewRepresentable {
    var items: [String]
    
    func makeUIView(context: Context) -> PhotosSegmentedControl {
        let segmentedControl = PhotosSegmentedControl()
        segmentedControl.items = items
        return segmentedControl
    }
    func updateUIView(_ uiView: PhotosSegmentedControl, context: Context) {
        uiView.items = items
    }
}

struct PhotosSegmentedControlPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            PhotosSegmentedControlRepresentable(items: ["Years", "Months", "Days", "All Photos"])
                .environment(\.colorScheme, .light)
                .background(Color.white)
            PhotosSegmentedControlRepresentable(items: ["Years", "Months", "Days", "All Photos"])
                .environment(\.colorScheme, .dark)
                .background(Color.black)
        }
        .previewLayout(.fixed(width: 375, height: 40))
    }
}
#endif
