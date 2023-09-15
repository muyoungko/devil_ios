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
    @objc static public func pay(on vc: UIViewController, customerKey: String, orderId: String, orderName: String, amount: double_t,
                                 name: String, email: String, phone: String, completion:@escaping (Any?)->()) {
        
        //        let tossPayments = TossPayments(clientKey: customerKey)
        //        tossPayments.delegate = self
        //        tossPayments.requestPayment(결제수단, 결제정보, on: self)
        
        let popupVC = DevilTossPaymentsController()
        popupVC.amount = amount
        popupVC.orderId = orderId
        popupVC.orderName = orderName
        popupVC.customerKey = customerKey
        popupVC.name = name
        popupVC.email = email
        popupVC.phone = phone
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
    
    @objc static public func handleOpenUrl(_ url:URL) -> Bool {
        
        return false
    }
}
