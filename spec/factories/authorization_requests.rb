FactoryBot.define do
  factory :authorization_request do
    intitule { 'Intitule' }
    description { 'description' }
    sequence(:external_id) { |n| n.to_s }
    user { build(:user, :with_full_name) }
    status { 'draft' }

    trait :without_external_id do
      external_id { nil }
    end

    trait :with_contacts do
      contacts do
        [
          build(:contact, :with_full_name, :business),
          build(:contact, :with_full_name, :tech)
        ]
      end
    end

    trait :with_token do
      token { create(:token) }
    end

    trait :submitted do
      with_token
      with_contacts

      first_submitted_at { DateTime.now }
      status { 'submitted' }
    end

    trait :validated do
      submitted

      validated_at { DateTime.now }
      status { 'validated' }
    end
  end
end
