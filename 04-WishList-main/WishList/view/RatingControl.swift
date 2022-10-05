//
//  RatingControl.swift
//  WishList
//
//  Created by 钱正轩 on 2020/11/2.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    //MARK: Properties
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    @IBInspectable var heartSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var heartCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Private Methods
    
    private func setupButtons(){
        for button in ratingButtons{
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        
        let bundle = Bundle(for: type(of: self))
        let filledHeart = UIImage(named: "filledHeart", in: bundle, compatibleWith: self.traitCollection)
        let emptyHeart = UIImage(named: "emptyHeart", in: bundle, compatibleWith: self.traitCollection)
        let highlightedHeart = UIImage(named: "highlightedHeart", in: bundle, compatibleWith: self.traitCollection)
        
        for index in 0..<heartCount{
            let button = UIButton()
            
            button.setImage(emptyHeart, for: .normal)
            button.setImage(filledHeart, for: .selected)
            button.setImage(highlightedHeart, for: .highlighted)
            button.setImage(highlightedHeart, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: heartSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: heartSize.width).isActive = true
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            button.accessibilityLabel = "Set \(index + 1) star rating"
            
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        
        updateButtonSelectionStates()
    }
    
    //MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton){
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        
        if selectedRating == rating{
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func updateButtonSelectionStates() {
        for(index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
            
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero"
            } else {
                hintString = nil
            }
            
            let valueString:String?
            switch(rating){
            case 0:
                valueString = "No rating set"
            case 1:
                valueString = "1 heart set"
            default:
                valueString = "\(rating) hearts set"
            }
            
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
    }
}
