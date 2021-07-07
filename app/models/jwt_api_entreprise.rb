class JwtApiEntreprise < ApplicationRecord
  include RandomToken

  belongs_to :user
  has_many :contacts, dependent: :delete_all
  has_and_belongs_to_many :roles

  scope :access_request_survey_not_sent, -> { where(access_request_survey_sent: false) }
  scope :not_blacklisted, -> { where(blacklisted: false) }
  scope :issued_in_last_seven_days, -> { where(created_at: 3.weeks.ago..1.week.ago) }
  scope :unexpired, -> { where('exp > ?', Time.zone.now.to_i) }

  def mark_access_request_survey_sent!
    update_attribute(:access_request_survey_sent, true)
  end

  def rehash
    AccessToken.create(token_payload)
  end

  def access_roles
    self.roles.pluck(:code)
  end

  def user_friendly_exp_date
    "#{Time.zone.at(exp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
  end

  def renewal_url
    "#{Rails.configuration.jwt_renewal_url}#{authorization_request_id}"
  end

  def user_and_contacts_email
    Set[*contacts.pluck(:email)] << user.email
  end

  def generate_magic_link_token
    token = random_token_for(:magic_link_token)
    update(
      magic_link_token: token,
      magic_link_issuance_date: Time.zone.now
    )
  end

  # TODO XXX This is temporary, the real "subject" of a JWT is set into the
  # #temp_use_case attribute when the #subject was fill with a SIRET number
  # (legacy reasons). Fix when the #temp_use_case attirbute isn't use anymore
  def displayed_subject
    temp_use_case || subject
  end

  private

  def token_payload
    payload = {
      uid: self.user_id,
      jti: self.id,
      roles: self.roles.pluck(:code),
      sub: self.subject,
      iat: self.iat,
      version: self.version
    }
    # JWT is by design expired if exp is null
    payload[:exp] = self.exp unless self.exp.nil?
    payload
  end
end
