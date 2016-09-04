class Manage::VotersController < ManageController

  def index
    @voters = VotingApiRequest
                       .new(Vaalit::VotingApi::VOTERS_URI)
                       .get

    @api_voter = ApiVoter.new()
  end

  def create
    @api_voter = ApiVoter.new(params["api_voter"])

    response = VotingApiRequest
               .new(Vaalit::VotingApi::VOTERS_URI)
               .post(voter: @api_voter.attributes)

    if response.is_a?(Net::HTTPSuccess)
      flash[:notice] = "Created voter: #{@api_voter.name} (student_number: #{@api_voter.student_number})"
      redirect_to manage_voters_path
    else
      body = JSON.parse(response.body)
      flash.now[:alert] = "Error #{body["status"]}: #{body["error"]} #{body["exception"]}"
      render :edit
    end
  end

  def edit
  end

end
