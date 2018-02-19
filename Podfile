source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'
use_frameworks!

def development_pods
	pod 'Alamofire'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RealmSwift'
    pod 'Kingfisher'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest',     '~> 4.0'
end

target 'MarvelApp' do
  development_pods

  target 'MarvelAppTests' do
    inherit! :search_paths
    testing_pods
  end

end
