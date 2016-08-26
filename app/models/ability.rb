class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdvocateUser.new # guest user (not logged in)
    initialize_roles(user)

    # Controllers which are not provided by ActiveAdmin do not get authorized.
    # ActiveAdmin controller always authorizes, therefore access to login must
    # explicitly be granted.
    can :login, :admin
  end

  def admin(user)
    can :access, :admin
    can :manage, :all

    # Being signed-in as an AdminUser and VotingAreaUser at the same time
    # does not work with marking votes. (Dependency on current_user.voting_area).
    cannot :access, :voting
  end

  def secretary(user)
    can :access, :admin
    can :read, ActiveAdmin::Page, :name => "Dashboard"

    can [:read, :new, :create, :update], Candidate

    can [:read, :new, :create, :done], ElectoralAlliance
    can :update, ElectoralAlliance do |alliance|
      not alliance.secretarial_freeze?
    end
  end

  def advocate(user)
    can :access, :advocate if GlobalConfiguration.advocate_login_enabled?

    can [:manage, :index, :new, :show, :edit, :update, :create, :destroy], [ElectoralAlliance, Candidate]

    if not GlobalConfiguration.candidate_nomination_period_effective?
      cannot [:create, :new, :update, :destroy], ElectoralAlliance
      cannot [:create, :new, :destroy], Candidate
    end

    if GlobalConfiguration.candidate_data_frozen?
      cannot [:create, :new, :update, :destroy, :edit], [ElectoralAlliance, Candidate]
    end
  end

  def voting_area(user)
    can :access, [:voters, :voting]

    if Time.now > Vaalit::Voting::CALCULATION_BEGINS_AT
      can :manage, [:vote_amounts]
    end

  end

  private

  def initialize_roles(user)
    case user.class.to_s
      when "AdminUser"
        initialize_admin(user)
      when "VotingAreaUser"
        initialize_voting_area(user)
      when "AdvocateUser"
        initialize_advocate(user)
      else
        raise "Current user class could not be determined. This is a bug."
    end
  end

  # Authorize a secretary or a non-restricted admin.
  def initialize_admin(user)
    send user.role, user
  end

  def initialize_advocate(user)
    send :advocate, user
  end

  def initialize_voting_area(user)
    send :voting_area, user
  end
end
