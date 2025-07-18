import UIKit
import SwiftUI

// MARK: — SwiftUI Preview Wrapper
struct AnalysisViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AnalysisViewController {
        AnalysisViewController(direction: .outcome)
    }
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
        // no-op
    }
}

struct AnalysisViewControllerPreview_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisViewControllerPreview()
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: — Your UIViewController
class AnalysisViewController: UIViewController {
    // MARK: UI Elements
    private let headerContainer = UIView()
    private let startPicker = UIDatePicker()
    private let endPicker = UIDatePicker()
    private let sumLabel = UILabel()
    private let sortControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["По дате", "По сумме"])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    private let analizLabel: UILabel = {
        let k = UILabel()
        k.text = "Анализ"
        k.font = .systemFont(ofSize: 42, weight: .bold)
        k.textColor = .black
        return k
    }()
    private let opsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "ОПЕРАЦИИ"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.dataSource = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        t.backgroundColor = .white
        t.separatorStyle = .singleLine
        t.separatorColor = .lightGray
        t.separatorInset = .init(top: 0, left: 56, bottom: 0, right: 16)
        t.rowHeight = 56
        t.layer.cornerRadius = 12
        return t
    }()
    private var tableHeightConstraint: NSLayoutConstraint!
    
    // MARK: Data & VM
    private var transactions: [Transaction] = []
    private let viewModel: HistoryViewModel
    private let networkUIUtil = NetworkUIUtil()
    
    // MARK: Init
    init(direction: Direction) {
        self.viewModel = HistoryViewModel(direction: direction)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Анализ"
        view.backgroundColor = .systemGroupedBackground
        configurePickers()
        configureSumLabel()
        setupLayout()
        setupActions()
        loadData()
    }
    
    // MARK: Configure Subviews
    private func configurePickers() {
        [startPicker, endPicker].forEach {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .compact
            let bg = UIColor(named: "MainColor")!.withAlphaComponent(0.2)
            $0.backgroundColor = bg
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.tintColor = UIColor(named: "MainColor")
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 100)
            ])
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }
    
    private func configureSumLabel() {
        sumLabel.font = .systemFont(ofSize: 16, weight: .bold)
        sumLabel.textAlignment = .right
        sumLabel.text = "0 ₽"
    }
    
    // MARK: Layout
    private func setupLayout() {
        view.addSubview(analizLabel)
        analizLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 36)
        analizLabel.pinLeft(to: view, 16)
        
        headerContainer.backgroundColor = .white
        headerContainer.layer.cornerRadius = 10
        view.addSubview(headerContainer)
        headerContainer.pinLeft(to: view, 16)
        headerContainer.pinRight(to: view, 16)
        headerContainer.pinTop(to: analizLabel.bottomAnchor, 26)
        
        let startRow = makeRow(labelText: "Начало", accessory: startPicker)
        let endRow = makeRow(labelText: "Конец", accessory: endPicker)
        let sortRow = makeRow(labelText: "Сортировка", accessory: sortControl)
        let sumRow = makeRow(labelText: "Сумма", accessory: sumLabel)
        
        let divider1 = makeDivider()
        let divider2 = makeDivider()
        let divider3 = makeDivider()
        
        let headerStack = UIStackView(arrangedSubviews: [
            startRow, divider1, endRow, divider2, sortRow, divider3, sumRow
        ])
        headerStack.axis = .vertical
        headerStack.spacing = 7
        headerContainer.addSubview(headerStack)
        headerStack.pin(to: headerContainer, 16)
        
        view.addSubview(opsTitleLabel)
        opsTitleLabel.pinLeft(to: view, 16)
        opsTitleLabel.pinTop(to: headerContainer.bottomAnchor, 63)
        
        view.addSubview(tableView)
        tableView.pinLeft(to: view, 16)
        tableView.pinRight(to: view, 16)
        tableView.pinTop(to: opsTitleLabel.bottomAnchor, 28)
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint.isActive = true
    }
    
    private func makeDivider() -> UIView {
        let d = UIView()
        d.backgroundColor = UIColor.lightGray.withAlphaComponent(0.43)
        d.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            d.heightAnchor.constraint(equalToConstant: 1)
        ])
        return d
    }
    
    private func makeRow(labelText: String, accessory: UIView) -> UIStackView {
        let label = UILabel()
        label.text = labelText
        label.font = .systemFont(ofSize: 16)
        let spacer = UIView()
        let h = UIStackView(arrangedSubviews: [label, spacer, accessory])
        h.axis = .horizontal
        h.spacing = 8
        return h
    }
    
    // MARK: Actions
    private func setupActions() {
        startPicker.addTarget(self, action: #selector(pickerChanged(_:)), for: .valueChanged)
        endPicker.addTarget(self, action: #selector(pickerChanged(_:)), for: .valueChanged)
        sortControl.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)
    }
    
    @objc private func pickerChanged(_ sender: UIDatePicker) {
        if sender === startPicker && startPicker.date > endPicker.date {
            endPicker.setDate(startPicker.date, animated: true)
        }
        if sender === endPicker && endPicker.date < startPicker.date {
            startPicker.setDate(endPicker.date, animated: true)
        }
        loadData()
    }
    
    @objc private func sortChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            transactions.sort { $0.transactionDate > $1.transactionDate }
        case 1:
            transactions.sort { $0.amount > $1.amount }
        default: break
        }
        tableView.reloadData()
    }
    
    // MARK: Loading
    private func loadData() {
        Task { @MainActor in
            do {
                try await networkUIUtil.perform(in: self) {
                    await self.viewModel.load()
                    return ()
                }
                transactions = viewModel.transactions
                sumLabel.text = " \(viewModel.total.formatted(.currency(code: "RUB")))"
                tableView.reloadData()
                tableView.layoutIfNeeded()
                tableHeightConstraint.constant = tableView.contentSize.height
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            } catch {
                // Error handling is managed by NetworkUIUtil
            }
        }
    }
}

// MARK: – UITableViewDataSource
extension AnalysisViewController: UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }
    
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tx = transactions[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        cfg.text = tx.category.name
        cfg.secondaryText = tx.comment
        if let circle = UIImage.circleEmoji(
            emoji: String(tx.category.emoji),
            diameter: 32,
            circleColor: UIColor(named: "MainColor")!.withAlphaComponent(0.2),
            fontSize: 20
        ) {
            cfg.image = circle
        }
        let amountLabel = UILabel()
        amountLabel.text = tx.amount.formatted(.currency(code: "RUB"))
        amountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        amountLabel.textColor = .label
        amountLabel.sizeToFit()
        cell.accessoryView = amountLabel
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = .lightGray
        cell.contentConfiguration = cfg
        return cell
    }
}

extension UIImage {

  static func circleEmoji(
    emoji: String,
    diameter: CGFloat,
    circleColor: UIColor,
    fontSize: CGFloat
  ) -> UIImage? {
    let size = CGSize(width: diameter, height: diameter)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    defer { UIGraphicsEndImageContext() }

    // 1) Draw the circle
    let circleRect = CGRect(origin: .zero, size: size)
    circleColor.setFill()
    UIBezierPath(ovalIn: circleRect).fill()

    // 2) Draw the emoji centered in that circle
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: fontSize)
    ]
    let textSize = (emoji as NSString).size(withAttributes: attributes)
    let textOrigin = CGPoint(
      x: (diameter - textSize.width) / 2,
      y: (diameter - textSize.height) / 2
    )
    (emoji as NSString).draw(at: textOrigin, withAttributes: attributes)

    return UIGraphicsGetImageFromCurrentImageContext()
  }
}

    

