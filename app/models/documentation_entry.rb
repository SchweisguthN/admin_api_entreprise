# frozen_string_literal: true

class DocumentationEntry
  include ActiveModel::Model
  include ActiveModelAlgoliaSearchable

  attr_accessor :title, :introduction, :sections

  def self.developers
    build_documentation_entries('documentation_entries.pages.developers')
  end

  def self.guide_migration
    build_documentation_entries('documentation_entries.pages.guide_migration')
  end

  def anchor
    title.parameterize
  end

  def introduction_markdownify
    MarkdownInterpolator.new(introduction).perform unless introduction.nil?
  end

  def self.build_documentation_entries(i18n_key)
    I18n.t(i18n_key).map do |entry|
      new(
        title: entry[:title],
        introduction: entry[:introduction],
        sections: entry[:sections]
      )
    end
  end
end
