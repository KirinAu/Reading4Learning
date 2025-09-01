import SwiftUI
import UIKit

#if canImport(Lottie)
import Lottie
#endif

struct SimpleLottieView: View {
    let animationName: String
    let size: CGSize
    
    var body: some View {
        LottieWrapperView(animationName: animationName)
            .frame(width: size.width, height: size.height)
    }
}

struct LottieWrapperView: UIViewRepresentable {
    let animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // 尝试加载Lottie动画
        if let animation = loadLottieAnimation() {
            let animationView = createLottieView(with: animation)
            containerView.addSubview(animationView)
            
            // 设置约束
            animationView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
                animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            // 播放动画（如果支持）
            playAnimationIfPossible(animationView)
        } else {
            // 备用方案：使用系统图标 + 动画
            let fallbackView = createAnimatedFallbackView()
            containerView.addSubview(fallbackView)
            
            fallbackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                fallbackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                fallbackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                fallbackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                fallbackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 不需要更新
    }
    
    // MARK: - Private Methods
    
    private func loadLottieAnimation() -> Any? {
        // 尝试从Bundle加载Lottie动画文件
        if let path = Bundle.main.path(forResource: animationName, ofType: "json") {
            print("📁 找到Lottie文件: \(path)")
            return path
        }
        
        // 尝试从Assets加载
        if let data = NSDataAsset(name: animationName)?.data {
            print("📦 从Assets加载Lottie数据")
            return data
        }
        
        print("❌ 未找到Lottie动画文件: \(animationName)")
        return nil
    }
    
    private func createLottieView(with animation: Any) -> UIView {
        #if canImport(Lottie)
        // 如果Lottie库可用，创建真正的Lottie视图
        if let path = animation as? String,
           let lottieAnimation = LottieAnimation.filepath(path) {
            let animationView = LottieAnimationView()
            animationView.animation = lottieAnimation
            animationView.loopMode = .loop
            animationView.contentMode = .scaleAspectFit
            return animationView
        }
        
        if let data = animation as? Data,
           let lottieAnimation = try? LottieAnimation.from(data: data) {
            let animationView = LottieAnimationView()
            animationView.animation = lottieAnimation
            animationView.loopMode = .loop
            animationView.contentMode = .scaleAspectFit
            return animationView
        }
        #endif
        
        // 如果Lottie库不可用或加载失败，返回占位符
        return createAnimatedFallbackView()
    }
    
    private func playAnimationIfPossible(_ view: UIView) {
        #if canImport(Lottie)
        if let lottieView = view as? LottieAnimationView {
            lottieView.play()
        }
        #endif
    }
    
    private func createAnimatedFallbackView() -> UIView {
        let containerView = UIView()
        
        // 创建信封图标
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "envelope.fill")
        imageView.tintColor = UIColor(AppColors.primary)
        imageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.6)
        ])
        
        // 添加丰富的动画效果
        addRichAnimations(to: imageView)
        
        return containerView
    }
    
    private func addRichAnimations(to imageView: UIImageView) {
        // 1. 缩放动画
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 2.0
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 2. 旋转动画（轻微）
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = -0.05
        rotationAnimation.toValue = 0.05
        rotationAnimation.duration = 3.0
        rotationAnimation.autoreverses = true
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 3. 透明度动画
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = 1.5
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 4. 位移动画（轻微上下浮动）
        let translationAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        translationAnimation.fromValue = -5
        translationAnimation.toValue = 5
        translationAnimation.duration = 2.5
        translationAnimation.autoreverses = true
        translationAnimation.repeatCount = .infinity
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 添加所有动画
        imageView.layer.add(scaleAnimation, forKey: "scaleAnimation")
        imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        imageView.layer.add(opacityAnimation, forKey: "opacityAnimation")
        imageView.layer.add(translationAnimation, forKey: "translationAnimation")
    }
}

// MARK: - Auto Play Lottie View
struct AutoPlayLottieView: View {
    let animationName: String
    let size: CGSize
    @State private var hasPlayed: Bool = false
    
    var body: some View {
        AutoPlayLottieWrapperView(
            animationName: animationName,
            hasPlayed: $hasPlayed,
            triggerAnimation: .constant(false)
        )
        .frame(width: size.width, height: size.height)
        .onAppear {
            hasPlayed = false
        }
    }
}

// MARK: - Triggerable Lottie View
struct TriggerableLottieView: View {
    let animationName: String
    let size: CGSize
    @Binding var trigger: Bool
    @State private var hasPlayed: Bool = false
    @State private var hasInitialized: Bool = false
    
    var body: some View {
        AutoPlayLottieWrapperView(
            animationName: animationName,
            hasPlayed: $hasPlayed,
            triggerAnimation: $trigger
        )
        .frame(width: size.width, height: size.height)
        .onAppear {
            if !hasInitialized {
                // 第一次出现时播放动画
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    hasPlayed = false
                    trigger = true
                    hasInitialized = true
                }
            }
        }
        .onChange(of: trigger) { newValue in
            if newValue && hasInitialized {
                hasPlayed = false
            }
        }
    }
}

struct AutoPlayLottieWrapperView: UIViewRepresentable {
    let animationName: String
    @Binding var hasPlayed: Bool
    @Binding var triggerAnimation: Bool
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.isOpaque = false
        
        if let animation = loadLottieAnimation() {
            let animationView = createLottieView(with: animation)
            containerView.addSubview(animationView)
            
            animationView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
                animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            context.coordinator.animationView = animationView
        } else {
            let fallbackView = createAnimatedFallbackView()
            containerView.addSubview(fallbackView)
            
            fallbackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                fallbackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                fallbackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                fallbackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                fallbackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            context.coordinator.fallbackView = fallbackView
        }
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let lottieView = context.coordinator.animationView {
            updateLottieAnimation(lottieView)
        } else if let fallbackView = context.coordinator.fallbackView {
            updateFallbackAnimation(fallbackView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var animationView: UIView?
        var fallbackView: UIView?
    }
    
    private func loadLottieAnimation() -> Any? {
        if let path = Bundle.main.path(forResource: animationName, ofType: "json") {
            return path
        }
        
        if let data = NSDataAsset(name: animationName)?.data {
            return data
        }
        
        return nil
    }
    
    private func createLottieView(with animation: Any) -> UIView {
        #if canImport(Lottie)
        if let path = animation as? String,
           let lottieAnimation = LottieAnimation.filepath(path) {
            let animationView = LottieAnimationView()
            animationView.animation = lottieAnimation
            animationView.loopMode = .playOnce
            animationView.contentMode = .scaleAspectFit
            animationView.backgroundColor = .clear
            animationView.currentProgress = 0.0
            return animationView
        }
        
        if let data = animation as? Data,
           let lottieAnimation = try? LottieAnimation.from(data: data) {
            let animationView = LottieAnimationView()
            animationView.animation = lottieAnimation
            animationView.loopMode = .playOnce
            animationView.contentMode = .scaleAspectFit
            animationView.backgroundColor = .clear
            animationView.currentProgress = 0.0
            return animationView
        }
        #endif
        
        return createAnimatedFallbackView()
    }
    
    private func updateLottieAnimation(_ view: UIView) {
        #if canImport(Lottie)
        if let lottieView = view as? LottieAnimationView {
            // 对于AutoPlayLottieView：只在hasPlayed为false时播放动画
            // 对于TriggerableLottieView：只在triggerAnimation为true且hasPlayed为false时播放动画
            if (!triggerAnimation && !hasPlayed) || (triggerAnimation && !hasPlayed) {
                lottieView.currentProgress = 0.0
                lottieView.play { finished in
                    if finished {
                        hasPlayed = true
                        // 如果是TriggerableLottieView，动画播放完成后重置trigger
                        if triggerAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                triggerAnimation = false
                            }
                        }
                    }
                }
            }
        }
        #endif
    }
    
    private func updateFallbackAnimation(_ view: UIView) {
        if let imageView = view.subviews.first as? UIImageView {
            if !hasPlayed {
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.fromValue = 1.0
                animation.toValue = 1.2
                animation.duration = 0.5
                animation.autoreverses = true
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                
                imageView.layer.add(animation, forKey: "autoPlayAnimation")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    hasPlayed = true
                }
            }
        }
    }
    
    private func createAnimatedFallbackView() -> UIView {
        let containerView = UIView()
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "envelope.fill")
        imageView.tintColor = UIColor(AppColors.primary)
        imageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.6)
        ])
        
        return containerView
    }
}
