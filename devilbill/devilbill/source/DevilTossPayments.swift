//
//  DevilTossPayments.swift
//  devilbill
//
//  Created by Mu Young Ko on 2023/08/14.
//

import Foundation
import TossPayments
import UIKit

@objc
public class DevilTossPayments: NSObject {
    @objc public override init() {
        super.init()
    }
    
//    open func path(forResource name: String?, ofType ext: String?) -> String?
    @objc static public func pay(on vc: UIViewController, customerKey: String, orderId: String, orderName: String, amount: double_t, completion:@escaping (Any?)->()) {
        
        //        let tossPayments = TossPayments(clientKey: customerKey)
        //        tossPayments.delegate = self
        //        tossPayments.requestPayment(결제수단, 결제정보, on: self)
        
        let popupVC = DevilTossPaymentsController()
        popupVC.amount = amount
        popupVC.orderId = orderId
        popupVC.orderName = orderName
        popupVC.customerKey = customerKey
        popupVC.completion = completion;
        popupVC.modalPresentationStyle = .popover // 팝업 스타일 설정
        popupVC.preferredContentSize = CGSize(width: 300, height: 200) // 팝업 크기 설정
        if let popoverController = popupVC.popoverPresentationController {
            popoverController.sourceView = vc.view
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: vc.view.bounds.width, height: vc.view.bounds.height)
            popoverController.permittedArrowDirections = [] // 화살표 방향 설정
        }

        vc.present(popupVC, animated: true, completion: nil)
    }
    
    @objc func show() {
//        let widget = PaymentWidget(clientKey: key, customerKey: customerKey);
//        widget.delegate = self
//        widget.paymentMethodWidget?.widgetUIDelegate = self
//        widget.agreementWidget?.agreementUIDelegate = self
//        widget.paymentMethodWidget?.widgetStatusDelegate = self
//        widget.agreementWidget?.widgetStatusDelegate = self
//        
//        let paymentMethodWidget = widget.renderPaymentMethods(
//            amount: PaymentMethodWidget.Amount(
//                value: amount,
//                currency: "KRW",
//                country: "KR"
//            ),
//            options: PaymentMethodWidget.Options(variantKey: "CardOnly")
//        )
//        let agreementWidget = widget.renderAgreement()
//        
//        
//        let popupVC = UIViewController()
//        let view = popupVC.view as! UIView
//        
//        // 팝업 스타일 및 프레젠트
//        popupVC.modalPresentationStyle = .popover // 팝업 스타일 설정
//        popupVC.preferredContentSize = CGSize(width: 300, height: 200) // 팝업 크기 설정
//        if let popoverController = popupVC.popoverPresentationController {
//            popoverController.sourceView = vc.view
//            popoverController.sourceRect = CGRect(x: 0, y: 0, width: vc.view.bounds.width, height: vc.view.bounds.height)
//            popoverController.permittedArrowDirections = [] // 화살표 방향 설정
//        }
//        view.backgroundColor = UIColor.white
//        
//        let scrollView = UIScrollView()
//        view.addSubview(scrollView)
//        scrollView.alwaysBounceVertical = true
//        scrollView.keyboardDismissMode = .onDrag
//        
//        let stackView = UIStackView()
//        scrollView.addSubview(stackView)
//        stackView.axis = .vertical
//        stackView.spacing = 16
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        stackView.addArrangedSubview(paymentMethodWidget)
//        stackView.addArrangedSubview(agreementWidget)
//        
//        // 오토레이아웃 설정
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let scrollViewBottomAnchorConstraint = scrollView.bottomAnchor
//            .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            scrollViewBottomAnchorConstraint,
//            scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
//            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
//            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
//            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
//            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
//        ])
//
//        vc.present(popupVC, animated: true, completion: nil)
//        
//        
//        let button = UIButton(type: .system)
//        view.addSubview(button)
//        
//        button.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            button.heightAnchor.constraint(equalToConstant: 60),
//            button.topAnchor.constraint(equalTo: view.bottomAnchor),
//            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
//        ])
//        
//        button.setTitle("결제하기", for: .normal)
//        button.backgroundColor = UIColor.systemBlue
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
////        button.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
        
        
    }
    
    @objc static public func handleOpenUrl(_ url:URL) -> Bool {
        
        return false
    }
}
