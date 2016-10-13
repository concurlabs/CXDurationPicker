Pod::Spec.new do |s|
  s.name                    = "CXDurationPicker"
  s.version                 = "0.16.6"
  s.summary                 = "Custom UIView which allows user to select a date range from calendar."
  s.homepage                = "https://github.com/concurlabs/CXDurationPicker"
  s.license                 = "Apache 2"
  s.authors                 = { "Richard Puckett" => "richard.puckett@concur.com" }
  s.source                  = { :git => 'https://github.com/concurlabs/CXDurationPicker.git', :tag => s.version }
  s.ios.deployment_target   = "9.0"
  s.source_files            = "CXDurationPicker"
  s.ios.frameworks          = "CoreText"
  s.requires_arc            = true
end
