Pod::Spec.new do |s|
  s.name                    = "CXDurationPicker"
  s.version                 = "0.0.2"
  s.summary                 = "Custom UIView which allows user to select a date range from calendar."
  s.license                 = "Apache 2"
  s.authors                 = { "Richard Puckett" => "richard.puckett@concur.com" }
  s.ios.deployment_target   = "7.0"
  s.source_files            = "CXDurationPicker"
  s.ios.frameworks          = "CoreText"
  s.requires_arc            = true
end
