class Manage::ResultsController < ManageController
  respond_to :json

  def index
    @results = Result.for_listing
  end

  # The calculated format of the result is used for displaying a temporary result when executing the drawings.
  # It should be the only purpose (except for viewing the result in development environment).
  # Rendering the result view is *slow* and may result to request timeout. For any other production purposes,
  # use the file which is stored in S3.
  def show
    @result = ResultDecorator.decorate Result.find(params[:id])

    respond_to do |format|
      format.json { render locals: { result: @result } }
      format.html { render partial: "result", locals: { result_decorator: @result } }
    end
  end

  def json
    @result = ResultDecorator.decorate Result.find(params[:result_id])

    respond_to do |format|
      format.json { render params[:target], locals: { result: @result } }
    end
  end

  def publish
    result_publisher = ResultPublisher.new(Result.find(params[:result_id]))

    if result_publisher.publish!
      flash[:notice] = "Vaalitulos jonossa julkaistavaksi."
    else
      flash[:error] = "Vaalituloksen julkaisu epäonnistui."
    end

    redirect_to manage_results_path
  end

  def freeze
    Delayed::Job.enqueue(CreateFrozenResultJob.new)

    flash[:notice] = "Vaalitulos jonossa arvontoja varten. Odota muutama minuutti ja lataa sivu uudelleen."
    redirect_to draws_path
  end

  def fetch_votes
    raise "Expected exactly one voting area to be present" unless VotingArea.count == 1

    Delayed::Job.enqueue(ImportVotesJob.new(VotingArea.first))
    flash[:notice] = "Äänet haetaan taustalla. Odota muutama minuutti ja lataa sivu uudelleen."

    redirect_to action: :index
  end
end
