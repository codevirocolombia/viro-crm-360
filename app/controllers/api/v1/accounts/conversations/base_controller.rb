class Api::V1::Accounts::Conversations::BaseController < Api::V1::Accounts::BaseController
  before_action :conversation

  private

  def conversation
    @conversation ||= Current.account.conversations.find_by!(display_id: params[:conversation_id])
    auto_assign_conversation_on_view if auto_assign_on_current_action?
    authorize @conversation, :show?
  end

  def auto_assign_on_current_action?
    controller_path == 'api/v1/accounts/conversations/messages' && action_name == 'index'
  end

  def auto_assign_conversation_on_view
    return unless should_auto_assign_conversation_on_view?

    assign_conversation
  end

  def should_auto_assign_conversation_on_view?
    account_user = Current.account_user

    Current.user.is_a?(User) &&
      account_user&.agent? &&
      @conversation.status == 'open' &&
      @conversation.assignee_id.blank?
  end

  def assign_conversation
    Conversations::AssignmentService.new(
      conversation: @conversation,
      assignee_id: current_user.id,
      actor: Current.user
    ).perform
  rescue Conversations::AssignmentService::AssignmentError
    nil
  end
end
