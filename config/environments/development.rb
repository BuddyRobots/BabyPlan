Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.domain = "test.buddyrobots.com"

  config.wechat_app_id = "wx0bad9193f1246547"
  config.wechat_app_key = "68b29adfa28e31c6107d7a627373e74f"

  config.wechat_pay_app_id = "wx0bad9193f1246547"
  config.wechat_pay_app_key = "68b29adfa28e31c6107d7a627373e74f"
  
  config.wechat_pay_api_key = "bBdnzYarb9DQntl42QWxtC502K6r4l1G"

  config.wechat_mch_id = "1445887202"

  config.course_change_notice_template_id = "XaIM2TKa7w78F8J2qB2bTtcVf_PlDq2F_wao3dznJTE"
  config.course_start_notice_template_id = "nP01oidKj_p4cLFGuZws3yPWVAIt7IXi0P_tGPn45VU"
  config.book_return_notice_template_id = "2S4VVtCGxJsVpEeqJsmBBLOTjgBMiQFhX8k49jxZuSg"
  
end
