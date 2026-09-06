# frozen_string_literal: true

class AddConversationAssignmentLimitToAccountUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :account_users, :conversation_assignment_limit, :integer, null: false, default: 5

    add_check_constraint :account_users,
                         'conversation_assignment_limit BETWEEN 1 AND 20',
                         name: 'account_users_conversation_assignment_limit_range'
  end
end
