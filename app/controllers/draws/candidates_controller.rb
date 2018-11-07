class Draws::CandidatesController < DrawsController
  def show
    @draw = CandidateDraw.find(params[:id])
  end

  def update
    draw = CandidateDraw.find(params[:id])
    draw.give_order!(:candidate_draw_order, params[:draw_order], automatically?)

    redirect_to draws_path(anchor: "draw_#{draw.identifier}")
  end
end
