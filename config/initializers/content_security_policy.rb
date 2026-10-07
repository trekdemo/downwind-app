# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https
    policy.frame_ancestors :none
    policy.base_uri    :self
    policy.form_action :self
  end

  # Generate session nonces for the importmap and other inline scripts, and for
  # the <style> element Turbo injects for its progress bar. The nonce lives in
  # the session rather than being derived from `session.id`, because the id is
  # nil until the session is first written, which would emit an empty
  # `'nonce-'` on a visitor's first page. It must stay stable across requests
  # because Turbo Drive keeps the first document's CSP for later visits.
  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
