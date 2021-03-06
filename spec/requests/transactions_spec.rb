require 'spec_helper'

describe "/transactions/" do
  include Rack::Test::Methods

  def app
    SalesEngineWeb::Server
  end

  let!(:customer1){ SalesEngineWeb::Customer.create(:first_name => "Geoff", :last_name => "Schorkopf") }
  let!(:customer2){ SalesEngineWeb::Customer.create(:first_name => "Tim", :last_name => "Schorkopf") }
  let!(:ii1){ SalesEngineWeb::InvoiceItem.create(item_id: 1, invoice_id: 1, quantity: 9, unit_price: 100) }
  let!(:ii2){ SalesEngineWeb::InvoiceItem.create(item_id: 2, invoice_id: 1, quantity: 4, unit_price: 200) }
  let!(:ii3){ SalesEngineWeb::InvoiceItem.create(item_id: 1, invoice_id: 2, quantity: 5, unit_price: 200) }
  let!(:invoice1){ SalesEngineWeb::Invoice.create(:customer_id => 1, :merchant_id => 2, :status => "shipped") }
  let!(:invoice2){ SalesEngineWeb::Invoice.create(:customer_id => 1, :merchant_id => 3, :status => "shipped") }
  let!(:item1){ SalesEngineWeb::Item.create(name: 'Top', description: 'Spinning toy',
                unit_price: 7200, merchant_id: 1) }
  let!(:item2){ SalesEngineWeb::Item.create(name: 'Game Boy', description: 'Handheld toy',
                unit_price: 7200, merchant_id: 1) }
  let!(:item3){ SalesEngineWeb::Item.create(name: 'Cell phone', description: 'Communication device',
                unit_price: 35000, merchant_id: 1) }
  let!(:merchant1){ SalesEngineWeb::Merchant.create(name: "Jumpstart Lab")}
  let!(:merchant2){ SalesEngineWeb::Merchant.create(name: "gSchool")}
  let!(:trans1){SalesEngineWeb::Transaction.create(invoice_id: 1, result: 'failed', credit_card_number: 4567) }
  let!(:trans2){SalesEngineWeb::Transaction.create(invoice_id: 1, result: 'success', credit_card_number: 4567) }
  let!(:trans3){SalesEngineWeb::Transaction.create(invoice_id: 2, result: 'success', credit_card_number: 1234) }
  def get_json(url)
    get url
    JSON.parse(last_response.body)
  end

    describe "find" do
      it "returns transaction by id" do
        output = get_json "/transactions/find?id=#{ trans1.id }"
        expect( output['id'] ).to eq trans1.id
      end

      it "returns transaction by invoice_id" do
        output = get_json "/transactions/find?invoice_id=#{ trans1.invoice_id }"
        expect( output['invoice_id'] ).to eq trans1.invoice_id
      end
      
      it "returns transaction by cc" do
        output = get_json "/transactions/find?credit_card_number=#{ trans1.credit_card_number }"
        expect( output['credit_card_number'] ).to eq trans1.credit_card_number
      end
    end

    describe "find_all" do
      it "returns transactions by invoice_id" do
        output = get_json "/transactions/find_all?invoice_id=#{ trans1.invoice_id }"
        expect( output.count ).to eq 2
      end

      it "returns transactions by result" do
        output = get_json "/transactions/find_all?result=#{ trans1.result }"
        expect( output.count ).to eq 1
      end

      it "returns transaction by cc" do
        output = get_json "/transactions/find_all?credit_card_number=#{ trans1.credit_card_number }"
        expect( output.count ).to eq 2
      end
    end

    describe "random" do
      it "returns random transaction" do
        output = get_json "/transactions/random"
        expect( [ trans1.id, trans2.id, trans3.id ] ).to include( output['id'] )
      end
    end

    describe ":id/invoice" do
      it "returns the associated invoice" do
        output = get_json "/transactions/#{invoice1.id}/invoice"
        expect(output['customer_id']).to eq 1
        expect(output['merchant_id']).to eq 2
      end
    end

end