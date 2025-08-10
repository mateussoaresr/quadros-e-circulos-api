require 'rails_helper'

RSpec.describe "Frames API", type: :request do
  describe "POST /frames" do
    let(:frame_base_params) do
      {
        center_x: 400,
        center_y: 300,
        width: 800,
        height: 600
      }
    end

    context "quando cria um frame sem círculos" do
      it "retorna 201 Created" do
        post "/frames", params: { frame: frame_base_params }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["center_x"]).to eq("400.0")
        expect(json["circles"]).to eq([])
      end
    end

    context "quando cria um frame com círculos sem sobreposição" do
      let(:circles) do
        [
          { center_x: 100, center_y: 150, radius: 50 },
          { center_x: 300, center_y: 150, radius: 50 }
        ]
      end

      it "retorna 201 Created e cria os círculos" do
        post "/frames", params: { frame: frame_base_params.merge(circles: circles) }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["circles"].size).to eq(2)
      end
    end

    context "quando cria um frame com círculos com sobreposição" do
      let(:circles) do
        [
          { center_x: 100, center_y: 150, radius: 50 },
          { center_x: 130, center_y: 150, radius: 50 } # sobrepõe com o primeiro
        ]
      end

      it "retorna 422 Unprocessable Entity com erros" do
        post "/frames", params: { frame: frame_base_params.merge(circles: circles) }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].first).to include("overlaps")
      end
    end


    context "quando já existe um frame que sobrepõe o novo frame" do
      before do
        # Cria um frame que ocupa (0..800)x(0..600)
        Frame.create!(
          center_x: 400,
          center_y: 300,
          width: 800,
          height: 600
        )
      end

      let(:overlapping_frame_params) do
        {
          center_x: 450,  # Próximo ao frame existente, vai sobrepor
          center_y: 350,
          width: 300,
          height: 300
        }
      end

      it "retorna 422 Unprocessable Entity e erro de sobreposição" do
        post "/frames", params: { frame: overlapping_frame_params }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].first.downcase).to include("must not touch or intersect another frame")
      end
    end
  end

  describe "GET /frames/:id" do
    let!(:frame) { Frame.create!(center_x: 400, center_y: 300, width: 800, height: 600) }
    let!(:circle) { frame.circles.create!(center_x: 100, center_y: 150, radius: 50) }
    let!(:circle2) { frame.circles.create!(center_x: 350, center_y: 350, radius: 40) }
    let!(:circle3) { frame.circles.create!(center_x: 500, center_y: 400, radius: 30) }

    context "quando o frame existe e tem círculos" do
      it "retorna 200 OK com as informações e métricas corretas" do
        get "/frames/#{frame.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["center_x"].to_f).to eq(frame.center_x.to_f)
        expect(json["center_y"].to_f).to eq(frame.center_y.to_f)
        expect(json["total_circles"]).to eq(3)

        # O círculo mais 'alto' tem menor center_y (topo)
        expect(json["circle_top"]["center_y"]).to eq(circle.center_y.to_s)
        # O círculo mais 'baixo' tem maior center_y
        expect(json["circle_bottom"]["center_y"]).to eq(circle3.center_y.to_s)
        # O círculo mais à esquerda tem menor center_x
        expect(json["circle_left"]["center_x"]).to eq(circle.center_x.to_s)
        # O círculo mais à direita tem maior center_x
        expect(json["circle_right"]["center_x"]).to eq(circle3.center_x.to_s)
      end
    end

    context "quando o frame existe mas não tem círculos" do
      let!(:empty_frame) { Frame.create!(center_x: 1200, center_y: 900, width: 400, height: 400) }

      it "retorna métricas nulas para os círculos" do
        get "/frames/#{empty_frame.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["total_circles"]).to eq(0)
        expect(json["circle_top"]).to be_nil
        expect(json["circle_bottom"]).to be_nil
        expect(json["circle_left"]).to be_nil
        expect(json["circle_right"]).to be_nil
      end
    end

    context "quando o frame não existe" do
      it "retorna 404 Not Found com json de erro" do
        get "/frames/999999"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Frame not found")
      end
    end
  end
end
