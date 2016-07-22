Pod::Spec.new do |s|
  s.name             = "TorchORM"
  s.version          = "0.1.3"
  s.summary          = "Torch - Boilerplate-free CoreData bridge."
  s.description      = <<-DESC
                        Torch is an ORM library allowing you to use structs instead of classes for your models.
                       DESC

  s.homepage         = "https://github.com/SwiftKit/Torch"
  s.license          = 'MIT'
  s.author           = { "Tadeas Kriz" => "tadeas@brightify.org", "Filip Dolnik" => "filip@brightify.org" }
  s.source           = {
      :git => "https://github.com/SwiftKit/Torch.git",
      :tag => s.version.to_s
  }

  s.ios.deployment_target       = '8.0'
  s.osx.deployment_target       = '10.9'
  s.watchos.deployment_target   = '2.0'
  s.tvos.deployment_target      = '9.0'
  s.source_files                = ['Source/**/*.swift']
  s.preserve_paths              = ['Generator/**/*', 'run', 'build_generator']
  s.prepare_command             = <<-CMD
                                    git submodule update --init --recursive
                                    ./build_generator
                                CMD
  s.frameworks                  = 'CoreData'
  s.module_name                 = 'Torch'
  s.requires_arc                = true
  s.pod_target_xcconfig         = { 'ENABLE_BITCODE' => 'NO' }
end
