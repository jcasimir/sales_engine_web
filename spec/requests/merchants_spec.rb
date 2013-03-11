Bundler.require
require './lib/sales_engine_web/server'
require './lib/sales_engine_web/models/merchant'

describe "/merchants/" do
  include Rack::Test::Methods

  def app
    SalesEngineWeb::Server
  end

  before(:each) do
    merchant1 && merchant2
  end

  let(:merchant1){ SalesEngineWeb::Merchant.create(:id => 12, :name => "Jumpstart Lab") }
  let(:merchant2){ SalesEngineWeb::Merchant.create(:id => 13, :name => "gSchool") }
  let(:merchant3){ SalesEngineWeb::Merchant.create(:id => 14, :name => "Galvanize") }

  describe "random" do
    it "returns a random merchant" do
      get '/merchants/random'
      output = JSON.parse(last_response.body)
      expect( [ merchant1.id, merchant2.id ] ).to include( output['id'] )
    end
  end

  describe "find" do
    context "given id=12" do
      it "finds the merchant" do
        get '/merchants/find?id=12'
        output = JSON.parse(last_response.body)
        expect( output['id'] ).to eq 12
        expect( output['name'] ).to eq "Jumpstart Lab"
      end

      it "finds merchant1" do
        get "/merchants/find?id=#{merchant1.id}"
        output = JSON.parse(last_response.body)
        expect( output['id'] ).to eq merchant1.id
        expect( output['name'] ).to eq merchant1.name
      end

      it "finds merchant2" do
        get "/merchants/find?id=#{merchant2.id}"
        output = JSON.parse(last_response.body)
        expect( output['id'] ).to eq merchant2.id
        expect( output['name'] ).to eq merchant2.name
      end
    end

    context "given name='Jumpstart%20Lab'" do
      it "finds the merchant" do
        get "/merchants/find?name=Jumpstart%20Lab"
        output = JSON.parse(last_response.body)
        expect( output['id'] ).to eq merchant1.id
        expect( output['name'] ).to eq merchant1.name
      end
    end
  end
end