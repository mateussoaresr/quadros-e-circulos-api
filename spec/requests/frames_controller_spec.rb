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
end
