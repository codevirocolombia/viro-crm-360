class Api::V1::Accounts::Conversations::BaseController < Api::V1::Accounts::BaseController
  before_action :conversation

  private

  def conversation
    @conversation ||= Current.account.conversations.find_by!(display_id: params[:conversation_id])
    ensure_conversation_accessible_on_open!
    return if performed?

    authorize @conversation, :show?
  end

  def ensure_conversation_accessible_on_open!
  return unless Current.user.is_a?(User)

  account_user = Current.account_user
  return unless account_user&.agent? || account_user&.supervisor? || account_user&.call_center?
  return if @conversation.assignee_id == Current.user.id

  if @conversation.assignee_id.present?
    return if account_user.supervisor? || account_user.call_center?

    render json: { error: 'Esta conversación ya está asignada a otro agente' }, status: :forbidden
    return
  end

  return unless @conversation.status == 'open'

  assign_conversation_for_view
rescue Conversations::AssignmentService::AssignmentError => e
  render json: { error: e.message }, status: :forbidden
end

  def assign_conversation_for_view
    Conversations::AssignmentService.new(
      conversation: @conversation,
      assignee_id: current_user.id,
      actor: Current.user
    ).perform
  end
end
