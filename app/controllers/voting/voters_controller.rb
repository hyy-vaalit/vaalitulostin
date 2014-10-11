class Voting::VotersController < VotingController
  def index
    @voter_search = VoterSearch.new
  end

  def edit
    @voter = Voter.find params[:id]
  end

  def new
    @voter = Voter.new
  end

  def create
    @voter = Voter.new params[:voter]

    if @voter.save && @voter.mark_voted!(current_user.voting_area)
      flash[:notice] = "Luotiin uusi äänioikeutettu #{@voter.name} ja merkittiin hänet äänestäneeksi."

      redirect_and_show_voter(@voter)
    else
      flash[:alert] = "Äänioikeutetun luominen epäonnistui."
      render :new
    end
  end

  def search
    @voter_search = VoterSearch.new(params[:voter_search])
    @voters = []

    if @voter_search.valid?
      @voters = Voter.matching_name(@voter_search.name).matching_ssn(@voter_search.ssn).matching_student_number(@voter_search.student_number)
    end

  end

  def mark_voted
    @voter = Voter.find params[:voter_id]

    if @voter.mark_voted!(current_user.voting_area)
      flash[:notice] = "Henkilö '#{@voter.name}' merkitty äänestäneeksi."
      redirect_and_show_voter(@voter)
    else
      flash[:alert] = "Kirjaus epäonnistui! Henkilö äänestänyt alueella #{@voter.voting_area.name} klo #{@voter.voted_at.localtime}"
      redirect_to edit_voting_voter_path(@voter)
    end
  end

  protected

  # Search for one more time and display results only by SSN so that IF there was a typo,
  # there's now a last chance to see it before allowing the ballot.
  def redirect_and_show_voter(voter)
    redirect_to search_voting_voters_path(
                    :voter_search => {
                        :ssn => voter.ssn
                    }
                )
  end
end
