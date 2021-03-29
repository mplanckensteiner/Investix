//
//  CalculatorTableViewController.swift
//  Investix
//
//  Created by Miguel Planckensteiner on 2/18/21.
//

import UIKit
import Combine


class CalculatorTableViewController: UITableViewController {
    
    
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
    
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDayOfInvestmentTextField: UITextField!
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var dateSlider: UISlider!
    
    var asset: Asset?
    
    @Published private var initialDayOfInvestmentIndex: Int?
    @Published private var initialInvestmentAmount: Int?
    @Published private var monthlyDollarCostAveragingAmount: Int?
    
    private var subscribers = Set<AnyCancellable>()
    
    private let dcaService = DCAService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupTextFields()
        setupDateSlider()
        observeForm()
        resetViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initialInvestmentAmountTextField.becomeFirstResponder()
    }
    
    private func setupViews() {
        
        navigationItem.title = asset?.searchResult.name
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
        
        currencyLabels.forEach { (label) in
            label.text = asset?.searchResult.currency.addBrackets()
            
        }
    }
    
    private func setupTextFields() {
        
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDayOfInvestmentTextField.delegate = self
    }
    
    private func setupDateSlider() {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            
            let dateSliderCount = count - 1
            
            dateSlider.maximumValue = dateSliderCount.floatValue
        }
    }
    
    private func observeForm() {
        $initialDayOfInvestmentIndex.sink { [weak self] (index) in
            
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat {
                
                self?.initialDayOfInvestmentTextField.text = dateString
            }
            
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            
            self?.initialInvestmentAmount = Int(text) ?? 0
            //print("initialInvestmentTextField: \(text)")
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            
            self?.monthlyDollarCostAveragingAmount = Int(text) ?? 0
            
            //print("monthlyDollarTextField: \(text)")
        }.store(in: &subscribers)
        
        Publishers.CombineLatest3($initialInvestmentAmount, $monthlyDollarCostAveragingAmount, $initialDayOfInvestmentIndex).sink { [weak self] (initialInvestmentAmount, monthlyDollarCostAveragingAmount, initialDayOfInvestmentIndex) in
            
            guard let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyDollarCostAveragingAmount = monthlyDollarCostAveragingAmount,
                  let initialDayOfInvestmentIndex = initialDayOfInvestmentIndex,
                  let asset = self?.asset else { return }
            
            let result = self?.dcaService.calculate(asset: asset, initialInvestmentAmount: initialInvestmentAmount.doubleValue,
                                                    monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount.doubleValue,
                                                    initialDateOfInvestmentIndex: initialDayOfInvestmentIndex)
            
            let isProfitable = (result?.isProfitable == true)
            let gainSymbol = isProfitable ? "+" : ""
            
            //CURRENT VALUE LABEL
            self?.currentValueLabel.backgroundColor = isProfitable ? .themeGreenShade : .themeRedShade
            self?.currentValueLabel.text = result?.currentValue.currencyFormat
            
            //INVESTMENT AMOUNT LABEL
            self?.investmentAmountLabel.text = result?.investmentAmount.toCurrencyFormat(hasDecimalPlaces: false)
            
            //GAIN LABEL
            self?.gainLabel.text = result?.gainAmount.toCurrencyFormat(hasDollarSymbol: false, hasDecimalPlaces: false).prefix(withText: gainSymbol)
            
            //YIELD LABEL
            self?.yieldLabel.text = result?.yield.percentageFormatter.prefix(withText: gainSymbol).addBrackets()
            self?.yieldLabel.textColor =  isProfitable ? .systemGreen : .systemRed
            
            //ANUAL RETURN LABEL
            self?.annualReturnLabel.text = result?.annualReturn.percentageFormatter
            self?.annualReturnLabel.textColor = isProfitable ? .systemGreen : .systemRed
            
            //print("\(initialInvestmentAmount), \(monthlyDollarCostAveragingAmount), \(initialDayOfInvestmentIndex)")
            
        }.store(in: &subscribers)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDateSelection",
           
           let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController,
           
           let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.selectedIndex = initialDayOfInvestmentIndex
            dateSelectionTableViewController.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
                //print("Index: \(index)")
            }
        }
    }
    
    private func handleDateSelection(at index: Int) {
        
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos() {
            
            initialDayOfInvestmentIndex = index
            
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDayOfInvestmentTextField.text = dateString
        }
    }
    
    private func resetViews() {
        currentValueLabel.text = "0.00"
        investmentAmountLabel.text = "0.00"
        gainLabel.text = "-"
        yieldLabel.text = "-"
        annualReturnLabel.text = "-"
    }
    
    @IBAction func dateSliderDidChange(_ sender: UISlider) {
        
        initialDayOfInvestmentIndex = Int(sender.value)
        
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == initialDayOfInvestmentTextField {
            
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            return false
        }
        
        return true
    }
}
