Pod::Spec.new do |s|
  s.name         = "KRBeaconFinder"
  s.version      = "1.5.2"
  s.summary      = "Find beacons, simulate beacons advertising and integrate BLE functions."
  s.description  = <<-DESC
                   KRBeaconFinder can lazy scanning beacons, relax using CoreLocation to monitor beacon-regions or use CoreBluetooth (BLE) to scan. And auto pop-up the message to notify users when they locked on the screen. It also can simulate beacon adversting from peripheral adversting.
                   DESC
  s.homepage     = "https://github.com/Kalvar/ios-KRBeaconFinder"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Kalvar Lin" => "ilovekalvar@gmail.com" }
  s.social_media_url = "https://twitter.com/ilovekalvar"
  s.source       = { :git => "https://github.com/Kalvar/ios-KRBeaconFinder.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.public_header_files = 'KRBeaconFinder/**/*.h'
  s.source_files = 'KRBeaconFinder/**/*.{h,m}'
  s.frameworks   = 'Foundation', 'CoreBluetooth', 'CoreLocation'
end 