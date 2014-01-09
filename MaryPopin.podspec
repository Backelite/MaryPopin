Pod::Spec.new do |s|
  s.name         = "MaryPopin"
  s.version      = "1.1"
  s.summary      = "Category to display modal-like view controllers with more options"

  s.description  = <<-DESC
                    MaryPopin is a category to present view controllers in a supercalifragilisticexpialidocious way.
                   DESC

  s.homepage     = "https://github.com/Backelite/MaryPopin"
  s.license      = 'MIT'

  s.author       = "Backelite"

  s.platform     = :ios, '5.0'

  s.source       = { :git => "https://github.com/Backelite/MaryPopin.git", :commit => "9da533fcbec940e92bfa619684c37b7ab63c49c5" }

  s.source_files  = 'MaryPopin/**/*.{h,m}'

  s.framework  = 'UIKit'

  s.requires_arc = true

end
