# frozen_string_literal: true

module TaxCalculations
  class GiftAidCalculator
    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Sum net donations
      donations_net = IncomeSource.gift_aid_donations
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      # Gross-up: net / 0.8 = gross (25p per £1 gross)
      gross_up = donations_net.zero? ? 0 : (donations_net / 0.8 - donations_net)
      total_gross_donation = donations_net + gross_up

      # Record breakdown step
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "gift_aid",
        {
          donations_net: donations_net,
          gross_up: gross_up,
          total_gross_donation: total_gross_donation
        },
        total_gross_donation,
        "Gift Aid: £#{format('%.2f', donations_net)} grossed to £#{format('%.2f', total_gross_donation)}"
      )

      {
        donations_net: donations_net,
        gross_up: gross_up,
        total_gross_donation: total_gross_donation,
        band_extension: total_gross_donation
      }
    end
  end
end
