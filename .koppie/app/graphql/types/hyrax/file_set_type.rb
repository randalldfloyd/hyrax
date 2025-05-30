# frozen_string_literal: true

class Types::Hyrax::FileSetType < Types::BaseObject
  field :id, String, null: true
  field :label, String, null: true
  field :viewing_hint, String, null: true
  field :thumbnail, Types::Thumbnail, null: true

  def viewing_hint
    object.viewing_hint.try(:first)
  end

  def label
    object.title.try(:first)
  end

  def thumbnail
    #return unless ability&.can?(:manifest, object)
    return if object.try(:thumbnail_id).blank? || thumbnail_resource.blank?

    hyrax_thumbnail_path = Hyrax::CollectionThumbnailPathService.call(thumbnail_resource)
    return if hyrax_thumbnail_path.nil?

    # Explicitly set this nil if the service URL cannot be parsed
    iiif_service_url = nil
    service_substr = "/full/!200,150/0/default.jpg"
    if hyrax_thumbnail_path.include?(service_substr)
      iiif_service_url = hyrax_thumbnail_path.gsub(service_substr, "")
    end
    {
      id: thumbnail_resource.id.to_s,
      thumbnail_url: hyrax_thumbnail_path,
      iiif_service_url: iiif_service_url
    }
  end

  def thumbnail_resource
    object
  end

  delegate :ocr_content, to: :object
end
