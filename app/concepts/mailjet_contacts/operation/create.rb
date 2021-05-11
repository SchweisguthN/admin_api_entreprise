# frozen_string_literal: true

module MailjetContacts::Operation
  class Create < ::Trailblazer::Operation
    step :fetch_users
    step :build_payload
    step :create_to_mailjet

    def fetch_users(ctx, **)
      ctx[:users_relation] = ::User.added_since_yesterday.includes(:contacts)
      ctx[:users_relation].exists?
    end

    def build_payload(ctx, users_relation:, **)
      ctx[:serialized_contacts] = users_relation.find_each.map do |user|
        build_mailjet_payload(user)
      end

      ctx[:serialized_contacts].any?
    end

    def create_to_mailjet(ctx, serialized_contacts:, **)
      Mailjet::Contactslist_managemanycontacts.create(
        id:       ::Rails.application.credentials.mj_list_id!,
        action:   'addnoforce',
        contacts: serialized_contacts
      )

      true
    end

    private

    def build_mailjet_payload(user)
      {
        email: user.email,
        properties: {
          contact_demandeur:  user.contacts.map(&:contact_type).include?('other'),
          contact_métier:     user.contacts.map(&:contact_type).include?('admin'),
          contact_technique:  user.contacts.map(&:contact_type).include?('tech'),
          infolettre:         true,
          origine:            'dashboard',
          techlettre:         user.contacts.map(&:contact_type).include?('tech')
        }
      }
    end
  end
end
