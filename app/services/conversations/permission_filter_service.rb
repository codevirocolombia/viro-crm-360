class Conversations::PermissionFilterService
  attr_reader :conversations, :user, :account

  def initialize(conversations, user, account)
    @conversations = conversations
    @user = user
    @account = account
  end

  def perform
    return conversations if user_role.in?(%w[administrator supervisor])

    accessible_conversations
  end

  private

  def accessible_conversations
    assigned_conversations.or(participating_conversations)
  end

  def assigned_conversations
    conversations.where(assignee_id: user.id)
  end

  def participating_conversations
    conversations.where(id: user.participating_conversations.where(account_id: account.id).select(:id))
  end

  def account_user
    AccountUser.find_by(account_id: account.id, user_id: user.id)
  end

  def user_role
    account_user&.role
  end
end

Conversations::PermissionFilterService.prepend_mod_with('Conversations::PermissionFilterService')
