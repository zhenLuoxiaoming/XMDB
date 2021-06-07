#
#  Be sure to run `pod spec lint XMDB.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "XMDB"
  spec.version      = "0.0.8"
  spec.summary      = "FMDB封装"


  spec.description  = <<-DESC
            这个就是描述啊啊啊啊
                   DESC

  spec.homepage     = "https://github.com/zhenLuoxiaoming"



  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }




  spec.author             = { "罗晓明" => "542250137@qq.com" }


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.platform     = :ios, "10.0"



  spec.source       = { :git => "https://github.com/zhenLuoxiaoming/XMDB.git", :tag => "#{spec.version}" }

    #spec.source_files  = "XMDB/XMDB/*"
  spec.exclude_files = ""
  spec.swift_version = '4.2'

  spec.subspec 'Core' do |cs|
      cs.source_files  = "XMDB/XMDB/*"
  end
  
  spec.subspec 'XMCityCode' do |ss|
      ss.source_files = "XMDB/XMCityCode/*.swift"
      ss.resource = "XMDB/XMCityCode/amap_city_code.db"
      ss.dependency  'XMDB/Core'
      #ss.public_header_files = "XMDB/XMCityCode/*.swift"
  end

  spec.dependency "FMDB", "~> 2.7"
  spec.dependency "KakaJSON", "~> 1.1.2"
end
