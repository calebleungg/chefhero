# Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

# Rails.configuration.stripe = {
#   :public_key => Rails.application.credentials.dig(:stripe, :public_key),    
#   :secret_key => Rails.application.credentials.dig(:stripe, :secret_key)    
# }    

# Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

Stripe.api_key = Rails.application.credentials.stripe[:secret_key]