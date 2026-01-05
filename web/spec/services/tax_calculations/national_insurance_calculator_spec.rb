require 'rails_helper'

RSpec.describe TaxCalculations::NationalInsuranceCalculator do
  let(:tax_return) { create(:tax_return) }
  let(:calculator) { described_class.new(tax_return) }

  # 2024-25 NI Thresholds
  # Lower: £12,570 (no NI below)
  # Upper: £50,270
  # Basic: 8% on £12,571–£50,270
  # Higher: 2% on £50,271+

  describe '#calculate_class_1' do
    context 'income below threshold' do
      it 'returns zero NI for income below £12,570' do
        ni = calculator.calculate_class_1(12_570)
        expect(ni).to eq(0)
      end
    end

    context 'basic rate NI only' do
      it 'calculates 8% on earnings above threshold' do
        # £40,000 income
        # NI: (£40,000 - £12,570) * 8% = £27,430 * 8% = £2,194.40
        ni = calculator.calculate_class_1(40_000)
        expect(ni).to be_within(0.01).of(2_194.40)
      end

      it 'handles exact upper threshold' do
        # £50,270 income
        # NI: (£50,270 - £12,570) * 8% = £37,700 * 8% = £3,016
        ni = calculator.calculate_class_1(50_270)
        expect(ni).to be_within(0.01).of(3_016.00)
      end
    end

    context 'basic and higher rate NI' do
      it 'calculates 8% + 2% across threshold' do
        # £60,000 income
        # Basic: (£50,270 - £12,570) * 8% = £37,700 * 8% = £3,016
        # Higher: (£60,000 - £50,270) * 2% = £9,730 * 2% = £194.60
        # Total: £3,016 + £194.60 = £3,210.60
        ni = calculator.calculate_class_1(60_000)
        expect(ni).to be_within(0.01).of(3_210.60)
      end

      it 'handles high income correctly' do
        # £100,000 income
        # Basic: £37,700 * 8% = £3,016
        # Higher: (£100,000 - £50,270) * 2% = £49,730 * 2% = £994.60
        # Total: £4,010.60
        ni = calculator.calculate_class_1(100_000)
        expect(ni).to be_within(0.01).of(4_010.60)
      end
    end

    context 'edge cases' do
      it 'returns zero for zero income' do
        ni = calculator.calculate_class_1(0)
        expect(ni).to eq(0)
      end

      it 'handles very high income' do
        ni = calculator.calculate_class_1(1_000_000)
        expect(ni).to be > 19_000  # Should be substantial
      end
    end
  end
end
