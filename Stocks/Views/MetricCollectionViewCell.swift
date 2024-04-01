//
//  MetricCollectionViewCell.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 1.04.24.
//

import UIKit

/// Metric table cell
final class MetricCollectionViewCell: UICollectionViewCell {
    /// Cell id
    static let identifier = "MetricCollectionViewCell"

    /// Metric table cell viewModel
    struct ViewModel {
        let name: String
        let value: String
    }

    /// Name label
    private let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    /// Value label
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubviews(nameLabel, valueLabel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 3, y: 0, width: nameLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3, y: 0, width: valueLabel.width, height: contentView.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }

    /// Configure view
    /// - Parameter viewModel: Views ViewModel
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name+":"
        valueLabel.text = viewModel.value
    }
}
