require 'rails_helper'

RSpec.describe TaxCalculations::TaxBandCalculator do
  let(:tax_return) { create(:tax_return) }
  let(:calculator) { described_class.new(tax_return) }

  # Reference calculations for 2024-25
  # PA = £12,570, Basic rate £20% to £50,270, Higher £40%, Additional £45%

  describe '#calculate' do
    context 'basic rate tax only' do
      it 'calculates tax for income in basic rate band' do
        # £40,000 taxable: £40,000 * 20% = £8,000
        result = calculator.calculate(40_000)
        expect(result[:basic_rate_tax]).to eq(8_000.00)
        expect(result[:higher_rate_tax]).to eq(0)
        expect(result[:additional_rate_tax]).to eq(0)
        expect(result[:total_income_tax]).to eq(8_000.00)
      end

      it 'handles exact basic rate limit' do
        # £50,270 taxable: £50,270 * 20% = £10,054
        result = calculator.calculate(50_270)
        expect(result[:total_income_tax]).to eq(10_054.00)
      end
    end

    context 'basic and higher rate tax' do
      it 'calculates tax across bands' do
        # £70,000 taxable
        # Basic: £50,270 * 20% = £10,054
        # Higher: (£70,000 - £50,270) * 40% = £19,730 * 40% = £7,892
        # Total: £10,054 + £7,892 = £17,946
        result = calculator.calculate(70_000)
        expect(result[:basic_rate_tax]).to eq(10_054.00)
        expect(result[:higher_rate_tax]).to be_within(0.01).of(7_892.00)
        expect(result[:total_income_tax]).to be_within(0.01).of(17_946.00)
      end
    end

    context 'all three bands' do
      it 'calculates tax across all bands' do
        # £150,000 taxable
        # Basic: £50,270 * 20% = £10,054
        # Higher: (£125,140 - £50,270) * 40% = £74,870 * 40% = £29,948
        # Additional: (£150,000 - £125,140) * 45% = £24,860 * 45% = £11,187
        # Total: £10,054 + £29,948 + £11,187 = £51,189
        result = calculator.calculate(150_000)
        expect(result[:basic_rate_tax]).to eq(10_054.00)
        expect(result[:higher_rate_tax]).to be_within(0.01).of(29_948.00)
        expect(result[:additional_rate_tax]).to be_within(0.01).of(11_187.00)
        expect(result[:total_income_tax]).to be_within(0.01).of(51_189.00)
      end
    end

    context 'edge cases' do
      it 'returns zero tax for zero income' do
        result = calculator.calculate(0)
        expect(result[:total_income_tax]).to eq(0)
      end

      it 'handles negative income gracefully' do
        result = calculator.calculate(-1_000)
        expect(result[:total_income_tax]).to eq(0)
      end
    end
  end
end
