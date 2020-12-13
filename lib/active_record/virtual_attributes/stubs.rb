require "active_record"

class Arel::Attributes::SpecialAttribute < Arel::Attributes::Attribute
  attr_reader :arel
  def initialize(table, name, arel)
    super(table, name)
    @arel = arel
  end
end

# think this is standard extension and not monkey patching
module Arel # :nodoc: all
  module Visitors
    class ToSql
      private
        def visit_Arel_Attributes_SpecialAttribute(o, collector)
          visit o.arel, collector
        end
    end
  end
end

module ActiveRecord
  module VirtualAttributes
    module VirtualDelegates
    end
    module VirtualIncludes
    end
    module VirtualArel
    end
    module VirtualTotal
      module VirtualIncludes
      end
    end
  end

  class Relation
    # monkey patch
    # may need to extend these to introduce the allow_alias concept here
       def arel_column(field, &block)
        field = klass.attribute_aliases[field] || field
        from = from_clause.name || from_clause.value

        if klass.columns_hash.key?(field) && (!from || table_name_matches?(from))
          table[field]
        elsif klass.attribute_names.include?(field)
          virtual_attribute_arel_column(table, field, &block)
        elsif field.match?(/\A\w+\.\w+\z/)
          table, column = field.split(".")
          predicate_builder.resolve_arel_attribute(table, column) do
            lookup_reflection_from_join_dependencies(table)
          end
        else
          yield field
        end
      end

      def virtual_attribute_arel_column(table, field, allow_alias=true)
        arel = klass.arel_attribute(field)
        if arel.nil?
          yield field
        else
          # TODO: need to fix the alias here
          if allow_alias && arel && arel.respond_to?(:as) && !arel.kind_of?(Arel::Nodes::As) && !arel.try(:alias)
            arel = arel.as(connection.quote_column_name(field.to_s))
          end
          Arel::Attributes::SpecialAttribute.new(table, field, arel)
        end
      end

  end

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

    # def self.arel_attribute(column_name, arel_table = self.arel_table)
    #     byebug if name == "Author"
    #     super
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

    def self.virtual_attribute(name, type, **options)
      ## issue: type can be callable to delay lookup until after class load
      ## not sure if still necessary but this will break
      ## typically used for delegation
      attribute(name, type, **options.except(:arel, :uses))
      # @arel ||= {}
      # @arel[name.to_s] = options[:arel] if options[:arel]
      define_virtual_arel(name, options[:arel]) if options[:arel]
      define_virtual_include(name, options[:uses]) if options[:uses]
    end

    # includes
      class_attribute :_virtual_arel, :instance_accessor => false, :default => {}
    # end

      def self.define_virtual_arel(name, arel)
        self._virtual_arel = _virtual_arel.merge(name.to_s => arel)
      end

      def self.define_virtual_include(name, options)
      end

      def self.virtual_attribute?(field)
        !columns_hash.key?(field) && attribute_names.include?(field)
      end

      ## TODO: just brought this in
      ## need to define the arel properly
      ## need to define virtual_attribute / attribute_alias(maybe?)
      ## think the generation is just fine
      def self.arel_attribute(column_name, arel_table = self.arel_table)
        load_schema
        if virtual_attribute?(column_name) && !attribute_alias?(column_name)
          if (col = _virtual_arel[column_name.to_s])
            col.call(arel_table)
          end
        else
          super
        end
      end

    def self.virtual_delegate(*_)
    end
  end
end

module VirtualFields
end
module VirtualAttributes
  module Type
    Symbol      = ActiveRecord::VirtualAttributes::Type::Symbol
    StringSet   = ActiveRecord::VirtualAttributes::Type::StringSet
    NumericSet  = ActiveRecord::VirtualAttributes::Type::NumericSet
  end
end
