class CallCenter::AvailabilityService
  TIME_ZONE = 'America/Bogota'
  ACTIVE_ASSIGNMENT_STATUSES = %i[open pending snoozed].freeze

  def initialize(account:, now: Time.current)
    @account = account
    @now = now.in_time_zone(TIME_ZONE)
  end

  def payload
    call_center_users.map { |account_user| user_payload(account_user) }
  end

  private

  attr_reader :account, :now

  def call_center_users
    @call_center_users ||= account.account_users
                                   .joins(:user)
                                   .includes(:user)
                                   .where(role: :call_center)
                                   .order('users.name ASC')
  end

  def access_policy_for(user)
    policies_by_user_id[user.id]
  end

  def policies_by_user_id
    @policies_by_user_id ||= account.agent_access_policies.index_by(&:user_id)
  end

  def in_shift?(account_user)
    policy = access_policy_for(account_user.user)

    policy.present? && policy.enabled? && policy.allows_hour?(now)
  end

  def active_conversation_count(account_user)
    account.conversations.where(
      assignee_id: account_user.user_id,
      status: ACTIVE_ASSIGNMENT_STATUSES
    ).count
  end

  def has_capacity?(account_user, assigned_count)
    limit = account_user.conversation_assignment_limit
    limit.blank? || assigned_count < limit
  end

  def user_payload(account_user)
    assigned_count = active_conversation_count(account_user)
    limit = account_user.conversation_assignment_limit
    in_shift = in_shift?(account_user)
    has_capacity = has_capacity?(account_user, assigned_count)

    {
      id: account_user.user_id,
      name: account_user.user.name,
      email: account_user.user.email,
      in_shift: in_shift,
      assigned_conversation_count: assigned_count,
      conversation_assignment_limit: limit,
      has_capacity: has_capacity,
      available_for_assignment: in_shift && has_capacity
    }
  end
end
