//
//  DevilTossPaymentsController.swift
//  devilbill
//
//  Created by Mu Young Ko on 2023/08/14.
//

import Foundation
import TossPayments
import UIKit

@objc
public class DevilTossPaymentsController: UIViewController {
    
    public lazy var scrollView = UIScrollView()
    public lazy var stackView = UIStackView()
    public var scrollViewBottomAnchorConstraint: NSLayoutConstraint?
    public var widget: PaymentWidget!
    private lazy var button = UIButton()
    public var customerKey: String!
    public var appScheme: String!
    public var amount: Double!
    public var orderId: String!
    public var orderName: String!
    public var name: String!
    public var phone: String!
    public var email: String!
    public var completion: ((Any?) -> Void)?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        
        stackView.spacing = 24
        stackView.axis = .vertical
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollViewBottomAnchorConstraint = scrollView.bottomAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollViewBottomAnchorConstraint,
            scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        self.scrollViewBottomAnchorConstraint = scrollViewBottomAnchorConstraint
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.scrollViewBottomAnchorConstraint?.isActive = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        button.backgroundColor = .systemBlue
        button.setTitle("결제하기", for: .normal)
        button.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
        
        
        
        let path = Bundle.main.path(forResource: "devil", ofType:"plist")!
        let dict = NSDictionary(contentsOfFile: path)
        let clientKey = dict!["TossPaymentsClientKey"] as! String
        appScheme = dict!["TossPaymentsAppScheme"] as! String
        
        widget = PaymentWidget(clientKey: clientKey, customerKey: customerKey as String);
        widget.delegate = self
        widget.paymentMethodWidget?.widgetUIDelegate = self
        widget.agreementWidget?.agreementUIDelegate = self
        widget.paymentMethodWidget?.widgetStatusDelegate = self
        widget.agreementWidget?.widgetStatusDelegate = self

        let paymentMethodWidget = widget.renderPaymentMethods(
            amount: PaymentMethodWidget.Amount(
                value: amount,
                currency: "KRW",
                country: "KR"
            ),
            options: PaymentMethodWidget.Options(variantKey: "CardOnly")
        )
        let agreementWidget = widget.renderAgreement()
        
        stackView.addArrangedSubview(paymentMethodWidget)
        stackView.addArrangedSubview(agreementWidget)
        
    }
    
    @objc func requestPayment() {
        widget.requestPayment(
            info: DefaultWidgetPaymentInfo(
                orderId: orderId,
                orderName: orderName,
                appScheme: appScheme
            )
        )
    }
}


extension DevilTossPaymentsController {
    @objc func textFieldDidChanged(_ sender: Any) {
        if let amountString = (sender as? UITextField)?.text,
           let amount = Double(amountString) {
            widget.updateAmount(amount)
        }
    }
}

extension DevilTossPaymentsController: TossPaymentsDelegate {
    public func handleSuccessResult(_ success: TossPaymentsResult.Success) {
        
        let bundleIdentifier = Bundle.main.bundleIdentifier
        
        var res: [String: Any] = [
            "r": true,
            "type": "toss",
            "payment_key" : success.paymentKey,
            "order_id" : orderId,
            "order_name" : orderName,
            "customer_id" : customerKey,
            "package" : bundleIdentifier,
            "name": name,
            "email": email,
            "phone": phone,
        ]
        
        self.dismiss(animated: true) {
            self.completion!(res)
        }
        
    }
    
    public func handleFailResult(_ fail: TossPaymentsResult.Fail) {
        
        var res: [String: Any] = [
            "r": false,
            "error_code": fail.errorCode,
            "msg": fail.errorMessage
        ]
        
        self.dismiss(animated: true) {
            self.completion!(res)
        }
    }
}

extension DevilTossPaymentsController: TossPaymentsWidgetUIDelegate {
    public func didReceivedCustomRequest(_ widget: PaymentMethodWidget, paymentMethodKey: String) {
        
    }
    
    public func didReceivedCustomPaymentMethodSelected(_ widget: PaymentMethodWidget, paymentMethodKey: String) {
        
    }
    
    public func didReceivedCustomPaymentMethodUnselected(_ widget: PaymentMethodWidget, paymentMethodKey: String) {
        
    }
    
    public func didUpdateHeight(_ widget: PaymentMethodWidget, height: CGFloat) {
        
    }
}

extension DevilTossPaymentsController: TossPaymentsAgreementUIDelegate {
    public func didUpdateHeight(_ widget: AgreementWidget, height: CGFloat) {
        
    }
    
    public func didUpdateAgreementStatus(_ widget: AgreementWidget, agreementStatus: AgreementStatus) {
        
        button.backgroundColor = agreementStatus.agreedRequiredTerms ? .systemBlue : .systemRed
        button.isEnabled = agreementStatus.agreedRequiredTerms
    }
}

extension DevilTossPaymentsController: TossPaymentsWidgetStatusDelegate {
    public func didReceivedLoad(_ name: String) {
        
    }
}
