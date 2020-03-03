
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

# Stripe.api_key = Rails.application.credentials.stripe[:secret_key]