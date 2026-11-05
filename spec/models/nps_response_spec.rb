require "rails_helper"

RSpec.describe NpsResponse, type: :model do
  it "aceita nota 0" do
    response = build(:nps_response, nota_geral: 0)

    expect(response).to be_valid
  end

  it "aceita nota 10" do
    response = build(:nps_response, nota_geral: 10)

    expect(response).to be_valid
  end

  it "rejeita nota menor que 0" do
    response = build(:nps_response, nota_geral: -1)

    expect(response).not_to be_valid
  end

  it "rejeita nota maior que 10" do
    response = build(:nps_response, nota_geral: 11)

    expect(response).not_to be_valid
  end
end