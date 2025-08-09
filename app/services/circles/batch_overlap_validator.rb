module Circles
  class BatchOverlapValidator
    CircleData = Struct.new(:center_x, :center_y, :radius)

    def initialize(circle_attrs_list)
      @circles = circle_attrs_list.map { |a|
        CircleData.new(a[:center_x], a[:center_y], a[:radius])
      }
      @errors = []
    end

    def valid?
      # Lazy enumeration com interrupção antecipada
      @circles.lazy.combination(2).any? do |a, b|
        overlaps?(a, b).tap do |ov|
          if ov
            @errors << "Circle at (#{a.center_x}, #{a.center_y}) overlaps with one at (#{b.center_x}, #{b.center_y})"
          end
        end
      end == false
    end

    def errors
      @errors
    end

    private

    def overlaps?(a, b)
      dx = a.center_x - b.center_x
      dy = a.center_y - b.center_y
      Math.sqrt(dx**2 + dy**2) <= (a.radius + b.radius)
    end
  end
end
