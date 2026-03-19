class CoursePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  def index?
    true
  end

  def teacher_index?
    user.present? && user.teacher?
  end

  def create?
    user.present? && user.teacher?
  end

  def show?
    true
  end

  def update?
    user.present? && user.teacher? && record.user_id == user.id
  end

  def destroy?
    user.present? && user.teacher? && record.user_id == user.id
  end

  def new?
    create?
  end

  def edit?
    update?
  end



  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
    def resolve
      scope.all
    end
  end
end
