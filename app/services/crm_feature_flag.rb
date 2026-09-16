class CrmFeatureFlag
  CONVERSATION_LIMITS = 'CRM_FEATURE_CONVERSATION_LIMITS_ENABLED'
  AGENT_ACCESS = 'CRM_FEATURE_AGENT_ACCESS_ENABLED'
  KANBAN = 'CRM_FEATURE_KANBAN_ENABLED'

  DEFAULTS = {
    CONVERSATION_LIMITS => true,
    AGENT_ACCESS => true,
    KANBAN => true
  }.freeze

  def self.enabled?(name)
    value = GlobalConfig.get_value(name)
    return DEFAULTS.fetch(name, true) if value.nil?

    ActiveModel::Type::Boolean.new.cast(value)
  end
end
