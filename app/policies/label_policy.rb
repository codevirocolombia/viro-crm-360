class LabelPolicy < ApplicationPolicy
  def index?
    @account_user.administrator? ||
      @account_user.agent? ||
      @account_user.supervisor? ||
      @account_user.call_center?
  end

  def update?
    @account_user.administrator?
  end

  def show?
    @account_user.administrator?
  end

  def create?
    @account_user.administrator?
  end

  def destroy?
    @account_user.administrator?
  end
end
