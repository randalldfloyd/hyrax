# frozen_string_literal: true

module Hyrax
  class ManifestStructureBuilderService
    class TopStructure
      attr_reader :structure, :resource

      ##
      # @param [Hash] structure the top structure node
      def initialize(structure, resource = nil)
        @structure = structure
        @resource = resource
      end

      ##
      # Retrieve the label for the Structure. If it's RTL return it as an RDF
      # Literal
      # @return [String, RDF::Literal]
      def label
        return structure_label
        return structure_label unless resource&.decorate&.imported_attribute(:language)
        RDF::Literal.new(structure_label, language: resource.decorate.imported_attribute(:language).first)
      end

      ##
      # Retrieve the ranges (sc:Range) for this structure
      # @return [TopStructure]
      def ranges
        @ranges ||= structure.nodes.select { |x| x.proxy.blank? }.map do |node|
          TopStructure.new(node, resource)
        end
      end

      # Retrieve the IIIF Manifest nodes for FileSet resources
      # @return [LeafStructureNode]
      def file_set_presenters
        @file_set_presenters ||= structure.nodes.select { |x| x.proxy.present? }.map do |node|
          LeafStructureNode.new(node)
        end
      end

      def structure_label
        structure.label.to_sentence
      end
    end

    ##
    # Class modeling the terminal nodes of IIIF Manifest structures
    class LeafStructureNode
      attr_reader :structure
      ##
      # @param [Hash] structure the structure terminal node
      def initialize(structure)
        @structure = structure
      end

      ##
      # Retrieve the ID for the node from the first proxy in the structure
      # @return [String]
      def id
        id = structure.proxy.first.to_s

        # This is ugly, but when walking the structure through JSON (i.e. to index to Solr),
        # the Valkyrie::ID is mishandled, which ends up as a stringified array by the time
        # we cast back to a structure object and arrive here.  So strip out the junk:
        id.gsub(/\[:id\, /, "").gsub(/\"/, "").gsub(/\]/, "")
      end
    end
  end
end
