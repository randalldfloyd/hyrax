# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'building a IIIF Manifest', :clean_repo do
  let(:work) { valkyrie_create(:comet_in_moominland, :public, description: ['a novel about moomins']) }
  let(:user) { create(:admin) }
  let(:file_path) { fixture_path + '/world.png' }
  let(:original_file) { File.open(file_path) }
  let(:uploaded_file) { FactoryBot.create(:uploaded_file, file: original_file) }
  let(:persister) { Hyrax.persister }

  let(:structure) do
    {
      "label": "Top!",
      "nodes": [
        {
          "label": "Chapter 1",
          "nodes": [
            {
              "proxy": work.member_ids[0]
            }
          ]
        },
        {
          "label": "Chapter 2",
          "nodes": [
            {
              "proxy": work.member_ids[1]
            }
          ]
        }
      ]
    }
  end

  before do
    5.times { build_a_file_set_with_an_image }
    persister.save(resource: work)
    Hyrax.index_adapter.save(resource: work)
    work.logical_structure = [Hyrax::Structure.new(structure)]
    Hyrax.persister.save(resource: work)

    sign_in user
  end

  it 'has a structure with ranges' do
    manifest_json = load_manifest_check_standards
    pending("Manifest builder is acting on Solr doc in this context, so need to index the work after save before these will work")
    expect(manifest_json['structures']).not_to be_empty

    manifest_structure = manifest_json['structures']
    expect(manifest_structure.count).to eq 3
  end

  def build_a_file_set_with_an_image
    file_set = valkyrie_create(:hyrax_file_set, title: ['page n'], creator: ['Jansson, Tove'], description: ['the nth page'])
    valkyrie_create(:hyrax_file_metadata, :original_file, :image, :with_file, original_filename: 'world.png', file_set: file_set, file: uploaded_file)
    persister.save(resource: file_set)
    work.member_ids << file_set.id
  end

  def load_manifest_check_standards
    visit "/concern/generic_works/#{work.id}/manifest"

    # maybe validate this with https://github.com/IIIF/presentation-validator/blob/master/schema/iiif_3_0.json ?
    manifest_json = JSON.parse(page.body)

    expect(manifest_json['label']).to eq 'Comet in Moominland'
    expect(manifest_json['description']).to contain_exactly('a novel about moomins')
    manifest_json
  end
end
