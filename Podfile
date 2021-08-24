# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CastrApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CastrApp

  # Rx Pods

  pod 'RxSwift', '~> 3.5'
  pod 'RxCocoa', '~> 3.5'
  pod 'RxKeyboard'

  # Firebase pods

  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Auth'
  pod 'Firebase/Messaging'

  # REST/JSON/Sockets pods

  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'Birdsong'

  # UI pods

  pod 'SDWebImage'
  pod 'DeckTransition'
  pod 'SwiftGifOrigin'
  pod 'BEMCheckBox'
  pod 'Hex'


  target 'Preprod-CastrAppTests' do
    inherit! :search_paths
    pod 'Firebase'
  end

  target 'Preprod-CastrAppUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
