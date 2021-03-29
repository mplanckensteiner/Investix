//
//  SearchPlaceHolderView.swift
//  Investix
//
//  Created by Miguel Planckensteiner on 2/17/21.
//

import UIKit

class SearchPlaceHolderView: UIView {
    
    private let imageView: UIImageView = {
        let image = UIImage(named: "imLaunch")
        let iv = UIImageView()
        iv.image = image
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Search for companies to calculate potential returns via dollar cost average"
        label.font = UIFont(name: "AvenirNext-Medium", size: 15)!
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
        
    }()
    
    private lazy var stackView: UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            imageView.heightAnchor.constraint(equalToConstant: 180)
            
        ])
    }
}
