# frozen_string_literal: true
module Hyrax
  class Structure < Valkyrie::Resource
    attribute :label, Valkyrie::Types::Set
    attribute :nodes, Valkyrie::Types::Array.of(StructureNode)
  end
end
