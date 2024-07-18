# frozen_string_literal: true
module Hyrax
  class StructureDecorator < Hyrax::ModelDecorator
    def form_label
      label.first
    end
  end
end
