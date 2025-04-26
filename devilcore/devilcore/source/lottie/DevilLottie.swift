//
//  Loading.swift
//  mydata
//
//  Created by Mu Young Ko on 2025/03/09.
//  Copyright © 2025 july. All rights reserved.
//

import Foundation
import UIKit
import Lottie

@objc
public class DevilLottie : NSObject {
    static let shared = DevilLottie() // 싱글턴 패턴 (필요하면 사용)
    
    
    @objc
    private var animationView: LottieAnimationView?

    @objc
    public static func show(in view: UIView) -> LottieAnimationView? {
        
        if(DevilLottie.shared.animationView == nil) {
            let animationView = LottieAnimationView(name: "loading")
            animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            animationView.center = view.center
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
            
            if view != nil {
                view.addSubview(animationView)
            }
            DevilLottie.shared.animationView = animationView
        }
        
        return DevilLottie.shared.animationView
    }

    @objc
    public static func generateView(WithData json: NSData) -> LottieAnimationView? {
        do {
            let animation = try JSONDecoder().decode(LottieAnimation.self, from: json as Data)
            let animationView = LottieAnimationView(animation: animation)
            animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()

            return animationView
        } catch {
            print("Failed to decode Lottie animation from JSON: \(error)")
            return nil
        }
    }
    
    @objc
    public static func generateView(name: String) -> LottieAnimationView? {
        
        let animationView = LottieAnimationView(name: name)
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        animationView.contentMode = .scaleAspectFit
        return animationView;
    }
    
    @objc
    public static func generateView(name: String, bundle: Bundle) -> LottieAnimationView? {
        
        let animationView = LottieAnimationView(name: name, bundle: bundle)
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        animationView.contentMode = .scaleAspectFit
        return animationView;
    }
    
    @objc
    public static func play(View view:LottieAnimationView) {
        view.play()
    }
    
    @objc
    public static func stop(View view:LottieAnimationView) {
        view.stop()
    }
    
    @objc
    public static func loop(View view:LottieAnimationView, Loop loop:Bool) {
        if loop {
            view.loopMode = .loop
        } else {
            view.loopMode = .playOnce
        }
    }
    
    @objc
    public static func hide() {
        DevilLottie.shared.animationView?.removeFromSuperview()
        DevilLottie.shared.animationView = nil
    }
    
    @objc
    public static func play(View view:LottieAnimationView, From from:CGFloat, To to:CGFloat) {
        view.play(fromFrame: from, toFrame: to) { animationFinished in
            view.isHidden = true
        }
    }
}
