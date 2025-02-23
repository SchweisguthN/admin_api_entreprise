class DatapassWebhook::ScheduleAuthorizationRequestEmails < ApplicationInteractor
  def call
    (datapass_webhooks_config_for_event[:emails] || []).each do |email_config|
      schedule_email(
        email_config.stringify_keys
      )
    end
  end

  private

  def schedule_email(email_config)
    return unless condition_on_authorization_met?(email_config['condition_on_authorization'])

    ScheduleAuthorizationRequestMailjetEmailJob.set(wait_until: extract_when_time(email_config['when'])).perform_later(
      context.authorization_request.id,
      context.authorization_request.status,
      build_mailjet_attributes(email_config)
    )
  end

  def condition_on_authorization_met?(condition_on_authorization)
    return true if condition_on_authorization.nil?

    AuthorizationRequestConditionFacade.new(context.authorization_request).public_send(condition_on_authorization)
  end

  def build_mailjet_attributes(email_config)
    {
      template_id: email_config['id'],
      vars: context.mailjet_variables
    }.merge(recipients_payload(email_config))
  end

  def recipients_payload(email_config)
    {
      to: recipient_payload(email_config['to'] || default_recipients),
      cc: recipient_payload(email_config['cc'])
    }.compact
  end

  def recipient_payload(user_strings_to_eval)
    return if user_strings_to_eval.blank?

    user_strings_to_eval.map do |user_string_to_eval|
      contact = user_string_to_eval.split('.').reduce(context) do |object, method|
        object = object.public_send(method)
      end

      {
        'email' => contact.email,
        'full_name' => contact.full_name
      }
    end
  end

  def default_recipients
    [
      'authorization_request.user'
    ]
  end

  def extract_when_time(when_time)
    Chronic.parse(when_time) || Time.now
  end

  def datapass_webhooks_config_for_event
    datapass_webhooks_config[context.event.to_sym] || { emails: [] }
  end

  def datapass_webhooks_config
    @datapass_webhooks_config ||= Rails.application.config_for('datapass_webhooks')
  end
end
