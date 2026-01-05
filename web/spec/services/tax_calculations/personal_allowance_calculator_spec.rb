require 'rails_helper'

RSpec.describe TaxCalculations::PersonalAllowanceCalculator do
  let(:tax_return) { create(:tax_return) }
  let(:calculator) { described_class.new(tax_return) }

  describe '#calculate' do
    context 'standard personal allowance' do
      it 'returns £12,570 for income under withdrawal threshold' do
        pa = calculator.calculate(50_000)
        expect(pa).to eq(12_570.00)
      end

      it 'returns £12,570 for income at withdrawal threshold' do
        pa = calculator.calculate(125_140)
        expect(pa).to eq(12_570.00)
      end
    end

    context 'personal allowance withdrawal' do
      it 'withdraws PA above £125,140 threshold' do
        # Income £125,140 + £1,000 = £126,140
        # Withdrawal: £1,000 * 0.5 = £500
        # PA: £12,570 - £500 = £12,070
        pa = calculator.calculate(126_140)
        expect(pa).to eq(12_070.00)
      end

      it 'reduces PA to zero when income is high enough' do
        # PA withdrawal: (£226,140 - £125,140) * 0.5 = £50,500
        # Since £50,500 > £12,570, PA becomes 0
        pa = calculator.calculate(226_140)
        expect(pa).to eq(0)
      end
    end

    context 'edge cases' do
      it 'handles zero income' do
        pa = calculator.calculate(0)
        expect(pa).to eq(12_570.00)
      end

      it 'handles very high income' do
        pa = calculator.calculate(1_000_000)
        expect(pa).to eq(0)
      end
    end
  end
end
