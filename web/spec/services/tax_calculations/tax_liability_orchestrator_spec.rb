require 'rails_helper'

RSpec.describe TaxCalculations::TaxLiabilityOrchestrator do
  let(:user) { create(:user) }
  let(:tax_year) { create(:tax_year) }
  let(:tax_return) { create(:tax_return, user: user, tax_year: tax_year) }
  let(:orchestrator) { described_class.new(tax_return) }

  # Integration tests: Known-good scenarios from HMRC

  describe '#calculate' do
    context 'basic employment income' do
      it 'calculates correct tax and NI for £50,000' do
        # Example: £50,000 employment income
        IncomeSource.create!(
          tax_return: tax_return,
          source_type: :employment,
          amount_gross: 50_000,
          amount_tax_taken: 7_500
        )

        liability = orchestrator.calculate

        # Calculation:
        # Gross: £50,000
        # PA: £12,570
        # Taxable: £37,430
        # Tax: £37,430 * 20% = £7,486
        # NI: (£50,000 - £12,570) * 8% = £37,430 * 8% = £2,994.40
        # Total: £7,486 + £2,994.40 = £10,480.40
        # Paid: £7,500
        # Owed: £10,480.40 - £7,500 = £2,980.40

        expect(liability.total_gross_income).to eq(50_000)
        expect(liability.taxable_income).to eq(37_430)
        expect(liability.basic_rate_tax).to be_within(0.01).of(7_486.00)
        expect(liability.class_1_ni).to be_within(0.01).of(2_994.40)
        expect(liability.total_tax_and_ni).to be_within(0.01).of(10_480.40)
        expect(liability.tax_paid_at_source).to eq(7_500)
        expect(liability.net_liability).to be_within(0.01).of(2_980.40)
      end

      it 'calculates higher rate tax for £70,000' do
        IncomeSource.create!(
          tax_return: tax_return,
          source_type: :employment,
          amount_gross: 70_000,
          amount_tax_taken: 11_000
        )

        liability = orchestrator.calculate

        # Gross: £70,000
        # PA: £12,570
        # Taxable: £57,430
        # Basic: £50,270 * 20% = £10,054
        # Higher: (£57,430 - £50,270) * 40% = £7,160 * 40% = £2,864
        # Tax: £12,918
        # NI: (£70,000 - £12,570) * 8% = £57,430 * 8% = £4,594.40
        # Total: £17,512.40
        # Owed: £17,512.40 - £11,000 = £6,512.40

        expect(liability.total_gross_income).to eq(70_000)
        expect(liability.taxable_income).to eq(57_430)
        expect(liability.basic_rate_tax).to be_within(0.01).of(10_054.00)
        expect(liability.higher_rate_tax).to be_within(0.01).of(2_864.00)
        expect(liability.class_1_ni).to be_within(0.01).of(4_594.40)
        expect(liability.total_tax_and_ni).to be_within(0.01).of(17_512.40)
        expect(liability.net_liability).to be_within(0.01).of(6_512.40)
      end

      it 'calculates additional rate tax for £150,000' do
        IncomeSource.create!(
          tax_return: tax_return,
          source_type: :employment,
          amount_gross: 150_000,
          amount_tax_taken: 40_000
        )

        liability = orchestrator.calculate

        # Gross: £150,000 (above PA withdrawal threshold)
        # PA withdrawal: (£150,000 - £125,140) * 0.5 = £12,430
        # PA: £12,570 - £12,430 = £140
        # Taxable: £150,000 - £140 = £149,860
        # Basic: £50,270 * 20% = £10,054
        # Higher: (£125,140 - £50,270) * 40% = £29,948
        # Additional: (£149,860 - £125,140) * 45% = £11,173.40
        # Total Tax: £51,175.40
        # NI (basic + higher): (£50,270 - £12,570) * 8% + (£150,000 - £50,270) * 2%
        #                     = £37,700 * 8% + £99,730 * 2% = £3,016 + £1,994.60 = £5,010.60
        # Total: £56,185.80
        # Owed: £56,185.80 - £40,000 = £16,185.80

        expect(liability.total_gross_income).to eq(150_000)
        expect(liability.higher_rate_tax).to be_within(0.01).of(29_948.00)
        expect(liability.additional_rate_tax).to be > 0
        expect(liability.net_liability).to be > 0
      end
    end

    context 'multiple income sources' do
      it 'aggregates income correctly' do
        # Two employments
        IncomeSource.create!(
          tax_return: tax_return,
          source_type: :employment,
          amount_gross: 30_000,
          amount_tax_taken: 4_000
        )
        IncomeSource.create!(
          tax_return: tax_return,
          source_type: :employment,
          amount_gross: 20_000,
          amount_tax_taken: 2_000
        )

        liability = orchestrator.calculate

        expect(liability.total_gross_income).to eq(50_000)
        expect(liability.tax_paid_at_source).to eq(6_000)
      end
    end

    context 'refund scenarios' do
      it 'calculates refund when too much tax paid' do
        IncomeSource.create!(
          tax_return: tax_return,
          source_type: :employment,
          amount_gross: 20_000,
          amount_tax_taken: 5_000  # More than needed
        )

        liability = orchestrator.calculate

        # Gross: £20,000
        # PA: £12,570
        # Taxable: £7,430
        # Tax: £7,430 * 20% = £1,486
        # NI: (£20,000 - £12,570) * 8% = £594.40
        # Total: £2,080.40
        # Refund: £5,000 - £2,080.40 = £2,919.60

        expect(liability.refund_due?).to be true
        expect(liability.net_liability).to be < 0
      end
    end

    context 'calculation tracking' do
      it 'records all calculation steps' do
        IncomeSource.create!(
          tax_return: tax_return,
          source_type: :employment,
          amount_gross: 50_000,
          amount_tax_taken: 7_500
        )

        liability = orchestrator.calculate

        breakdowns = TaxCalculationBreakdown.for_return(tax_return).to_a
        step_keys = breakdowns.map(&:step_key)

        expect(step_keys).to include('income_aggregation')
        expect(step_keys).to include('personal_allowance')
        expect(step_keys).to include('taxable_income')
        expect(step_keys).to include('tax_band_calculation')
        expect(step_keys).to include('class_1_ni')
        expect(step_keys).to include('final_liability')
      end
    end
  end
end
