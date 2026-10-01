class CallCenter::ConversationClaimPolicy
  DEFAULT_RELEASE_DELAY_SECONDS = 60
  ACTIVE_ASSIGNMENT_STATUSES = %i[open pending snoozed].freeze
  TIME_ZONE = 'America/Bogota'

  def initialize(conversation:, account_user:, now: Time.current)
    @conversation = conversation
    @account_user = account_user
    @account = conversation.account
    @now = now.in_time_zone(TIME_ZONE)
  end

  def allowed?
    return true unless conversation.open? && conversation.assignee_id.nil?

    return call_center_available? if account_user.call_center?
    return true unless call_center_users.exists?
    return true unless available_call_center_exists?

    priority_period_finished?
  end

  def error_message
    if account_user.call_center?
      'No puedes tomar esta conversación: estás fuera de jornada o ya alcanzaste tu cupo.'
    else
      'Esta conversación tiene prioridad temporal para los agentes Call Center.'
    end
  end

  private

  attr_reader :conversation, :account_user, :account, :now

  def call_center_users
    account.account_users.where(role: :call_center)
  end

  def available_call_center_exists?
    call_center_users.any? do |call_center|
      in_shift?(call_center) && has_capacity?(call_center)
    end
  end

  def call_center_available?
    in_shift?(account_user) && has_capacity?(account_user)
  end

  def in_shift?(user)
    policy = account.agent_access_policies.find_by(user_id: user.user_id)

    policy.present? && policy.enabled? && policy.allows_hour?(now)
  end

  def has_capacity?(user)
    limit = user.conversation_assignment_limit
    return true if limit.blank?

    active_count = account.conversations.where(
      assignee_id: user.user_id,
      status: ACTIVE_ASSIGNMENT_STATUSES
    ).count

    active_count < limit
  end

def priority_period_finished?
  conversation.updated_at <= now - release_delay_seconds.seconds
end

  def release_delay_seconds
    value = account.custom_attributes&.fetch(
      'call_center_release_delay_seconds',
      DEFAULT_RELEASE_DELAY_SECONDS
    ).to_i

    value.positive? ? value : DEFAULT_RELEASE_DELAY_SECONDS
  end
end
