Pod::Spec.new do |s|
  s.name          = "COOperation"
  s.version       = "0.0.3"
  s.summary       = "Library for working with compound operations"
  s.license       = 'MIT'
  s.authors       = { 
                      "Gleb Novik" => "g.novik@rambler-co.ru",
                      "Egor Tolstoy" => "e.tolstoy@rambler-co.ru"
                    }
  s.homepage      = "https://github.com/strongself/COOperation"
  s.source        = { :git => "https://github.com/strongself/COOperation.git", :tag => s.version.to_s }
  s.source_files  = 'Source/**/*.{h,m}'
  s.platform      = :ios, "7.0"
  s.requires_arc  = true
end
