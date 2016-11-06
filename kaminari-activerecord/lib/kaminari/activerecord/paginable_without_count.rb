# frozen_string_literal: true
module Kaminari
  module PaginableWithoutCount
    if ActiveRecord::Relation.instance_method(:load).parameters.empty?
      if ActiveRecord::VERSION::MAJOR == 4  # Rails 4.2.* and below
        def load
          if loaded? || limit_value.nil?
            super
          else
            _records  = limit(limit_value.succ).dup.to_a
            @has_next = !! _records.delete_at(limit_value.to_i)
            @records  = _records
            @loaded   = true

            self
          end
        end
      else # Rails 5.0.0 and 5.0.0.1
        def load
          if loaded? || limit_value.nil?
            super
          else
            _records  = limit(limit_value.succ).dup.to_a
            @has_next = !! _records.delete_at(limit_value.to_i)
            @records  = _records.freeze
            @loaded   = true

            self
          end
        end
      end
    else # Rails 5-0-stable and edge
      def load(&block)
        if loaded? || limit_value.nil?
          super
        else
          _records  = limit(limit_value.succ).dup.load(&block).to_a
          @has_next = !! _records.delete_at(limit_value.to_i)

          load_records(_records)
          self
        end
      end
    end

    def last_page?
      load
      !@has_next && !out_of_range?
    end

    def out_of_range?
      to_a.empty?
    end

    def total_pages
      raise "This scope is marked as a non-count paginate scope and can't be used in combination with `#paginate'. Use `#paginate_without_count' instead."
    end

    def total_count
      raise "This scope is marked as a non-count paginate scope and can't be used in combination with `#paginate'. Use `#paginate_without_count' instead."
    end
  end
end
