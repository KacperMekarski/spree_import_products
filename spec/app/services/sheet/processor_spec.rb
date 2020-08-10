require 'spec_helper'

RSpec.describe Sheet::Processor do
  describe '.call' do
    subject(:call) { described_class.new(data) }

    let(:file) { fixture_file_upload('spec/factories/files/sample.csv', 'text/csv') }
    let(:data) do
      { file: file }
    end
    let(:table) { CSV.parse(File.read(data[:file]), col_sep: ';', headers: true) }

    let(:availability_date_column) { table.by_col["availability_date"].compact.all? { |element| element.class == String } }
    let(:parsed_availability_date_column) { subject.products.map { |p| p["availability_date"].class == DateTime }.uniq.first }

    let(:stock_total_column) { table.by_col["stock_total"].compact.all? { |element| element.class == String } }
    let(:parsed_stock_total_column) { subject.products.map { |p| p["stock_total"].class == Integer }.uniq.first }

    let(:price_column) { table.by_col["price"].compact.all? { |element| element.class == String } }
    let(:parsed_price_column) { subject.products.map { |p| p["price"].class == Float }.uniq.first }

    let(:table_length) { 21 }
    let(:products_amount) { 3 }
    let(:row_length) { 8 }
    let(:parsed_row_length) { 7 }

    let(:csv_products_amount) { CSV.parse(File.read(data[:file]), col_sep: ';').map(&:compact).reject!(&:empty?).drop(1).length }
    let(:parsed_products_amount) { subject.products.length }


    it 'converts availability_date column to datetime' do
      expect(availability_date_column).to be true
      expect(subject.products).to be_empty

      subject.call

      expect(parsed_availability_date_column).to be true
    end

    it 'converts stock_total to integer' do
      expect(stock_total_column).to be true
      expect(subject.products).to be_empty

      subject.call

      expect(parsed_stock_total_column).to be true
    end

    it 'converts price to float number' do
      expect(price_column).to be true
      expect(subject.products).to be_empty

      subject.call

      expect(parsed_price_column).to be true
    end

    it 'removes empty rows' do
      expect(table.length).to eq table_length

      subject.call

      expect(parsed_products_amount).to eq products_amount
    end

    it 'removes empty values from row' do
      expect(table.first.length).to eq row_length

      subject.call

      expect(subject.products.first.length).to eq parsed_row_length
    end

    it 'returns same amount of objects' do
      subject.call

      expect(csv_products_amount).to eq parsed_products_amount
    end
  end
end