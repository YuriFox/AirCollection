//
//  StaticTableHeaderFooterView.swift
//  AirCollection
//
//  Created by Lysytsia Yurii on 25.10.2020.
//  Copyright © 2020 Lysytsia Yurii. All rights reserved.
//

import UIKit
import Source

class StaticTableHeaderFooterView: UITableViewHeaderFooterView, IdentificableView, NibLoadableView, ModelConfigurableView {

    // MARK: Outlet properties
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.groupTableViewBackground
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        self.titleLabel.textColor = UIColor.gray
    }
    
    // MARK: Functions
    func configure(model: Model) {
        self.titleLabel.text = model.title
    }
    
    // MARK: Helpers
    struct Model {
        let title: String
    }
    
}
