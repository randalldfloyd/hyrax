# frozen_string_literal: true

module Hyrax
  module LogicalStructureChangeSet
    def apply_logical_structure
      logical_order_value = (Array(fields["logical_structure"] || resource.logical_structure).first || Structure.new(label: "Logical"))
      logical_order = Hyrax::Structure.new(logical_order_value)
      logical_order.nodes = recursive_structure_node_delete(logical_order.nodes)
      Array(logical_order)
    end

    private

    def recursive_structure_node_delete(nodes)
      nodes.map do |node|
        next if node.proxy.present? && member_ids.exclude?(node.proxy.first.id)
        if node.nodes.present?
          node.nodes = recursive_structure_node_delete(node.nodes)
        end
        node
      end.compact
    end
  end
end
