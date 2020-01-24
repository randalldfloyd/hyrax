class CreateDerivativesJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  # @param use_valkyrie [Boolean] whether to use valkyrie support
  def perform(file_set, file_id, filepath = nil, use_valkyrie: false)
    if use_valkyrie
      file_set = Wings::ActiveFedoraConverter.new(resource: file_set).convert
    end

    return if file_set.video? && !Hyrax.config.enable_ffmpeg
    filename = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)

    file_set.create_derivatives(filename)

    # Reload from Fedora and reindex for thumbnail and extracted text
    file_set.reload
    file_set.update_index
    file_set.parent.update_index if parent_needs_reindex?(file_set)
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def parent_needs_reindex?(file_set)
    return false unless file_set.parent
    file_set.parent.thumbnail_id == file_set.id
  end
end
