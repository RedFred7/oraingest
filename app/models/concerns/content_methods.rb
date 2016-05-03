# ***********************************************************
# Modified By : Bhavana Ananda (Calvin Butcher)
# Date        : 23/03/2016

# Removed Databank
# ***********************************************************

require "json"
module ContentMethods
  extend ActiveSupport::Concern

  def list_open_access_content
    datastreams =[]
    unless self.accessRights.any? && self.accessRights.first.has_access_rights? && self.accessRights.first.embargoStatus.first == "Open access"
      return datastreams
    end
    if self.datastreams.keys().include? "descMetadata"
      datastreams << "descMetadata"
    end
    if self.datastreams.keys().include? "relationsMetadata"
      datastreams << "relationsMetadata"
    end
    self.hasPart.each do |hp|
      if hp.accessRights && hp.accessRights.first.has_access_rights? && hp.accessRights.first.embargoStatus.first == "Open access"
        datastreams << "#{hp.identifier.first}"
      end
    end
    datastreams
  end

  def content_datastreams
    self.datastreams.keys.select { |key| key.start_with?('content') and self.datastreams[key].content != nil }
  end


  def list_open_access_content_filenames
    content_filenames = Array.new
    # copy all the filenames of the content datastreams that have access rights
    self.content_datastreams.each do |dsid|
        unless self.list_open_access_content.exclude?(dsid)
          if (self.datastreams[dsid].content)['dsLabel']
            content_filenames << JSON.parse(self.datastreams[dsid].content)['dsLabel']
          end
        end
    end
    content_filenames
  end


  def has_all_access_rights?
    status = true
    # Does the object have access rights
    unless self.accessRights.any? && self.accessRights.first.has_access_rights?
      status = false
    end
    #Do all datastreams have access rights      
    self.content_datastreams.each do |dsid|
      unless self.relationsMetadata.datastream_has_access_rights?(dsid)
        status = false
      end
    end
    status
  end

  private

  def thumbnail_url(filename, size)
    icon = "fileIcons/default-icon-#{size}x#{size}.png"
    begin
      mt = MIME::Types.of(filename)
      extensions = mt.first.extensions
    rescue
      extensions = []
    end
    for ext in extensions
      if Rails.application.assets.find_asset("fileIcons/#{ext}-icon-#{size}x#{size}.png")
        icon = "fileIcons/#{ext}-icon-#{size}x#{size}.png"
      end
    end
    icon
  end

end

