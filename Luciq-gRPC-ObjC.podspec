Pod::Spec.new do |s|
  s.name             = "Luciq-gRPC-ObjC"
  s.version          = "0.3.0"
  s.summary          = "Capturing gRPC requests for iOS and tvOS"
  s.homepage         = "https://luciq.ai"
  s.license          = {
      :type => 'Commercial',
      :text => <<-LICENSE
                Copyright (C) 2025 Luciq
                Permission is hereby granted to use this framework as is, modification are not allowed.
                All rights reserved.
        
        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
        THE SOFTWARE.
      LICENSE
    }
  s.author           = { "Luciq" => "contact@luciq.ai" }
  s.ios.deployment_target = '15.0'
  s.tvos.deployment_target = '15.0'
  s.source           = { :git => "https://github.com/luciqai/luciqai-gRPC.git", :tag => "#{s.version}" }

  s.source_files = 'Luciq-grpc-objc/**/*.{h,m,swift}'
  s.requires_arc     = true
  s.dependency 'Luciq', '>= 18.0.0', '< 20.0.0'
  s.dependency 'gRPC'
end
