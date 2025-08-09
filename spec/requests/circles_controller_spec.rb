require 'rails_helper'

RSpec.describe "Circles API", type: :request do
  let!(:frame) { Frame.create!(center_x: 400, center_y: 300, width: 800, height: 600) }
  let!(:circle) { frame.circles.create!(center_x: 100, center_y: 150, radius: 50) }

  describe "POST /frames/:frame_id/circles" do
    let(:valid_circle_params) do
      {
        center_x: 200,
        center_y: 200,
        radius: 40
      }
    end

    context "quando adiciona um círculo válido que não sobrepõe" do
      it "retorna 201 Created" do
        post "/frames/#{frame.id}/circles", params: { circle: valid_circle_params }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["center_x"].to_f).to eq(200.0)
      end
    end

    context "quando adiciona um círculo que sobrepõe outro no frame" do
      let(:overlapping_circle_params) do
        {
          center_x: 130,
          center_y: 150,
          radius: 50
        }
      end

      it "retorna 422 Unprocessable Entity com erros" do
        post "/frames/#{frame.id}/circles", params: { circle: overlapping_circle_params }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include(/overlaps/i)
      end
    end

    context "quando envia dados inválidos" do
      let(:invalid_params) do
        {
          center_x: nil,
          center_y: 150,
          radius: 50
        }
      end

      it "retorna 422 com erros de validação" do
        post "/frames/#{frame.id}/circles", params: { circle: invalid_params }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"].any? { |msg| msg =~ /Center x/i }).to be true
      end
    end
  end

  describe "PUT /circles/:id" do
    context "quando atualiza um círculo com dados válidos sem sobreposição" do
      let(:valid_update_params) do
        {
          center_x: 200,
          center_y: 200,
          radius: 40
        }
      end

      it "retorna 200 OK e atualiza o círculo" do
        put "/circles/#{circle.id}", params: { circle: valid_update_params }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["center_x"].to_f).to eq(200.0)
        expect(json["center_y"].to_f).to eq(200.0)
        expect(json["radius"].to_f).to eq(40.0)
      end
    end

    context "quando atualiza um círculo que resultaria em sobreposição" do
      before do
        frame.circles.create!(center_x: 250, center_y: 200, radius: 40)
      end

      let(:overlapping_update_params) do
        {
          center_x: 240,
          center_y: 200,
          radius: 40
        }
      end

      it "retorna 422 Unprocessable Entity com erros de sobreposição" do
        put "/circles/#{circle.id}", params: { circle: overlapping_update_params }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include(/overlaps/i)
      end
    end

    context "quando atualiza com dados inválidos" do
      let(:invalid_update_params) do
        {
          center_x: nil,
          center_y: 200,
          radius: 40
        }
      end

      it "retorna 422 Unprocessable Entity com erros de validação" do
        put "/circles/#{circle.id}", params: { circle: invalid_update_params }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"].any? { |msg| msg =~ /Center x/i }).to be true
      end
    end
  end
end
