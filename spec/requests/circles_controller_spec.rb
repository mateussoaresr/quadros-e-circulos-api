require 'rails_helper'

RSpec.describe "Circles API", type: :request do
  let!(:frame) { Frame.create!(center_x: 400, center_y: 300, width: 800, height: 600) }
  let!(:circle) { frame.circles.create!(center_x: 100, center_y: 150, radius: 50) }
  let!(:circle2) { frame.circles.create!(center_x: 350, center_y: 350, radius: 40) }
  let!(:circle3) { frame.circles.create!(center_x: 500, center_y: 400, radius: 30) }

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

  describe "GET /circles" do
    context "quando busca círculos dentro de um raio sem frame_id" do
      it "retorna apenas os círculos completamente dentro do raio" do
        get "/circles", params: { center_x: 100, center_y: 150, radius: 60 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        # Deve conter circle (centro 100,150 r=50) dentro do raio 60
        expect(json.map { |c| c["id"] }).to include(circle.id)
        # circle2 (350,350) e circle3 (500,400) estão fora do raio 60
        expect(json.map { |c| c["id"] }).not_to include(circle2.id)
        expect(json.map { |c| c["id"] }).not_to include(circle3.id)
      end
    end

    context "quando busca círculos dentro de um raio filtrando por frame_id" do
      let!(:other_frame) { Frame.create!(center_x: 1000, center_y: 1000, width: 400, height: 400) }
      let!(:other_circle) { other_frame.circles.create!(center_x: 1010, center_y: 1010, radius: 20) }

      it "retorna apenas círculos do frame especificado que estão dentro do raio" do
        get "/circles", params: { center_x: 1000, center_y: 1000, radius: 50, frame_id: other_frame.id }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        puts response.body
        expect(json.map { |c| c["id"] }).to contain_exactly(other_circle.id)
        # Não deve retornar círculos de outro frame
        expect(json.map { |c| c["id"] }).not_to include(circle.id, circle2.id, circle3.id)
      end
    end

    context "quando não envia os parâmetros obrigatórios" do
      it "retorna 422 com mensagem de erro" do
        get "/circles", params: { center_x: 100 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("center_x, center_y and radius are required")
      end
    end

    context "quando não encontra círculos dentro do raio" do
      it "retorna um array vazio com 200 OK" do
        get "/circles", params: { center_x: 0, center_y: 0, radius: 10 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to eq([])
      end
    end
  end

  describe "DELETE /circles/:id" do
    it "deletes the circle and returns 204" do
      delete "/circles/#{circle.id}"
      expect(response).to have_http_status(204)
      expect(Circle.exists?(circle.id)).to be_falsey
    end

    it "returns 404 if circle not found" do
      delete "/circles/9999"
      expect(response).to have_http_status(404)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Circle not found")
    end
  end
end
