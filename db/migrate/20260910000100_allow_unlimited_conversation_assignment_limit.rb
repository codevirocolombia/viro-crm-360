# frozen_string_literal: true

class AllowUnlimitedConversationAssignmentLimit < ActiveRecord::Migration[7.1]
  def change
    remove_check_constraint :account_users,
                            name: 'account_users_conversation_assignment_limit_range'

    change_column_null :account_users, :conversation_assignment_limit, true

    add_check_constraint :account_users,
                         'conversation_assignment_limit IS NULL OR conversation_assignment_limit BETWEEN 1 AND 20',
                         name: 'account_users_conversation_assignment_limit_range'
  end
end
