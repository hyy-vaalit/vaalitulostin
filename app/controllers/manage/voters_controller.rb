class Manage::VotersController < ManageController
  def index
    response = VotingApiRequest
               .new(Vaalit::VotingApi::VOTERS_URI)
               .get

    body = JSON.parse response.body

    if response.is_a?(Net::HTTPSuccess)
      @voters = body
    else
      flash[:alert] = "Error #{response.code}: #{body}"
      @voters = []
    end

    @api_voter = ApiVoter.new
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
      flash.now[:alert] = "Error #{response.code}: #{body['error']} #{body['exception']}"
      render :edit
    end
  end

  def edit; end

  def send_link
    response = VotingApiRequest
               .new(Vaalit::VotingApi::SESSION_LINK_URI)
               .post(email: params["email"])

    if response.is_a?(Net::HTTPSuccess)
      flash[:notice] = "Sent sign in link to #{params['email']}"
    else
      flash[:alert] = "Failed to send sign in link to #{params['email']}"
    end

    redirect_to manage_voters_path
  end
end
