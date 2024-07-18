# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Hyrax::LogicalStructureChangeSet do
  subject(:change_set) { Hyrax::ChangeSet.for(work) }
  let(:work) { FactoryBot.valkyrie_create(:monograph, members: [file_set, second_file_set]) }
  let(:file_set) { FactoryBot.valkyrie_create(:hyrax_file_set) }
  let(:second_file_set) { FactoryBot.valkyrie_create(:hyrax_file_set) }

  describe "#logical_structure" do
    let(:structure) do
      {
        "label": "Top!",
        "nodes": [
          {
            "label": "Chapter 1",
            "nodes": [
              {
                "proxy": file_set.id
              }
            ]
          },
          {
            "label": "Chapter 2",
            "nodes": [
              {
                "proxy": second_file_set.id
              }
            ]
          }
        ]
      }
    end

    it "can set a whole structure all at once" do
      expect(change_set.validate(logical_structure: [structure])).to eq true

      structure = change_set.apply_logical_structure
      expect(structure[0].label).to eq ["Top!"]
      expect(structure[0].nodes[0].label).to eq ["Chapter 1"]
      expect(structure[0].nodes[0].nodes[0].proxy).to eq [file_set.id]
      expect(structure[0].nodes[1].label).to eq ["Chapter 2"]
      expect(structure[0].nodes[1].nodes[0].proxy).to eq [second_file_set.id]
    end

    it "has a default label" do
      expect(change_set.apply_logical_structure[0].label).to eq ["Logical"]
    end

    context "when a proxied resource does not exist" do
      let(:work) { FactoryBot.valkyrie_create(:monograph, members: [file_set]) }
      let(:structure) do
        {
          "label": "Top!",
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "proxy": file_set.id
                }
              ]
            },
            {
              "label": "Chapter 2",
              "nodes": [
                {
                  "proxy": "nonexistentresourceid"
                }
              ]
            }
          ]
        }
      end
      it "filters out those nodes" do
        expect(change_set.validate(logical_structure: [structure])).to eq true

        structure = change_set.apply_logical_structure
        expect(structure[0].label).to eq ["Top!"]
        expect(structure[0].nodes[0].label).to eq ["Chapter 1"]
        expect(structure[0].nodes[0].nodes[0].proxy).to eq [file_set.id]
        expect(structure[0].nodes[1].label).to eq ["Chapter 2"]
        expect(structure[0].nodes[1].nodes).to eq []
      end
    end
  end
end
