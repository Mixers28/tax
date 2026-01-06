# Exchange rate configuration
# Rates are cached from environment variables (set in docker-compose.yml)
# This allows fully offline operation without external API calls

class ExchangeRateConfig
  # Supported currencies for income entry
  SUPPORTED_CURRENCIES = ['GBP', 'EUR', 'USD'].freeze

  # Get current exchange rates from environment
  def self.get_rate(from_currency, to_currency = 'GBP')
    return 1.0 if from_currency == to_currency
    return 1.0 if from_currency == 'GBP' && to_currency == 'GBP'

    # Read from environment variables
    # Format: EUR_TO_GBP_RATE=0.8650
    env_var = "#{from_currency}_TO_#{to_currency}_RATE".upcase
    rate = ENV[env_var]

    if rate.present?
      rate.to_f
    else
      Rails.logger.warn("Exchange rate not configured: #{env_var}. Using 1.0 as default.")
      1.0
    end
  end

  # Convert amount from one currency to another
  def self.convert(amount, from_currency, to_currency = 'GBP')
    return amount.to_f if from_currency == to_currency

    rate = get_rate(from_currency, to_currency)
    (amount.to_f * rate).round(2)
  end

  # Get all available rates
  def self.all_rates
    rates = {}
    SUPPORTED_CURRENCIES.each do |currency|
      next if currency == 'GBP'
      rate = ENV["#{currency}_TO_GBP_RATE"]
      rates[currency] = rate&.to_f || 1.0
    end
    rates
  end
end
