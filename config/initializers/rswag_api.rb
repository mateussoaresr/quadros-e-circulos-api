Rswag::Api.configure do |c|
  # Pasta onde seu swagger.yaml está localizado
  c.swagger_root = Rails.root.join("swagger").to_s
end
