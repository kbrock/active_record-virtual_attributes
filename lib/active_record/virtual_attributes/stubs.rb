require "active_record"
module ActiveRecord
  class Base
    def self.virtual_total(name, *_)
      define_method(name) {}
    end

    def self.virtual_aggregate(*_)
    end

    # def self.arel_attribute(column_name, arel_table = self.arel_table)
    #   load_schema
    #   if virtual_attribute?(column_name) && !attribute_alias?(column_name)
    #     if (col = _virtual_arel[column_name.to_s])
    #       arel = col.call(arel_table)
    #       arel.name = column_name if arel.kind_of?(Arel::Nodes::Grouping)
    #       arel
    #     end
    #   else
    #     super
    #   end
    # end

    def self.virtual_average(*_)
    end
    def self.virtual_minimum(*_)
    end
    def self.virtual_maximum(*_)
    end
    def self.virtual_sum(*_)
    end
    def self.virtual_has_many(*_)
    end

    def self.virtual_has_one(*_)
    end

    def self.virtual_attribute(*_)
    end

    def self.virtual_delegate(*_)
    end
  end
end

module VirtualFields
end
