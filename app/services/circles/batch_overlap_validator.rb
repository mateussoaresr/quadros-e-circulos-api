module Circles
  class BatchOverlapValidator
    CircleData = Struct.new(:center_x, :center_y, :radius)

    def initialize(circle_attrs_list)
      @circles = circle_attrs_list.map do |a|
        CircleData.new(
          a[:center_x].to_f,
          a[:center_y].to_f,
          a[:radius].to_f
        )
      end
      @errors = []
    end

    def valid?
      # Ordena pelo eixo X para reduzir comparações
      @circles.sort_by!(&:center_x)

      @circles.each_with_index do |a, i|
        ((i + 1)...@circles.size).each do |j|
          b = @circles[j]

          # Se a distância no eixo X já for maior que a soma dos raios,
          # não tem como sobrepor com os próximos (pois estão mais à direita)
          break if (b.center_x - a.center_x) > (a.radius + b.radius)

          if overlaps?(a, b)
            @errors << "Circle at (#{a.center_x}, #{a.center_y}) overlaps with one at (#{b.center_x}, #{b.center_y})"
            return false # para imediatamente
          end
        end
      end

      true
    end

    def errors
      @errors
    end

    private

    def overlaps?(a, b)
      dx = a.center_x - b.center_x
      dy = a.center_y - b.center_y
      dist_sq = dx * dx + dy * dy
      radius_sum = a.radius + b.radius
      dist_sq <= radius_sum * radius_sum # sem usar sqrt
    end
  end
end
