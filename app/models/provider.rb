class Provider
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  attr_accessor :slug, :name, :link_external

  def self.all
    I18n.t('providers').map { |entry| new(entry) }
  end

  def link_catalogue_filtered_by
    "#{endpoints_path}?Endpoint[query]=#{slug}"
  end
end
