class ResultDecorator < ApplicationDecorator
  decorates :result

  delegate_all

  def potential_voters
    GlobalConfiguration.potential_voters_count
  end

  def votes_given
    GlobalConfiguration.votes_given
  end

  def candidates_to_elect
    Vaalit::Voting::ELECTED_CANDIDATE_COUNT
  end

  # vote_sum_cache is the same as
  # Vote.find_by_sql("select sum(votes.amount) as amount from votes").first.amount
  def votes_counted
    vote_sum_cache
  end

  def votes_counted_percentage
    return 0 if votes_accepted.zero? || votes_counted.zero?

    100.0 * votes_counted / votes_accepted
  end

  def votes_accepted
    GlobalConfiguration.votes_accepted || 0
  end

  def voting_percentage
    GlobalConfiguration.voting_percentage || 0
  end

  def formatted_timestamp(timestamp_method, opts = {})
    time = opts[:time] == false ? "" : " klo %H:%M:%S"
    self.send(timestamp_method).localtime.strftime("%d.%m.%Y" + time)
  end

  def most_recent?
    id == Result.last.id
  end

  def result_file_url
    "#{Vaalit::Results::PUBLIC_RESULT_URL}/#{filename}"
  end

  def to_html
    ApplicationController.renderer.render(
      partial: "manage/results/result",
      formats:  [:html],
      locals: { result_decorator: self }
    )
  end

  def to_json
    ApplicationController.renderer.render(
      template: "manage/results/show",
      formats:  [:json],
      locals:   { result: self }
    )
  end

  def to_json_candidates
    lookup_context = ActionView::LookupContext.new(ActionController::Base.view_paths)
    context = ActionView::Base.with_empty_template_cache.new(lookup_context, {}, nil)
    renderer = ActionView::Renderer.new(lookup_context)

    renderer.render(
      context,
      {
        template: "manage/results/candidates.json",
        locals: { result: self }
      }
    )
  end

  # EHDOKKAAT___________________________NUM_LIITTO__ÄÄNET___LVERT________RVERT_____
  # 1* Sukunimi, Etunimi 'Lempinimi.... 788 Humani   55    696.00000   2901.00000
  #
  # TODO: Ensure that these are actually sanitized:
  #  - candidate.candidate_name,
  #  - electoral_alliance.shorten
  #
  # rubocop:disable Rails/OutputSafety
  def candidate_result_line(candidate, index)
    (
      formatted_order_number(index + 1) +
      formatted_status_char(
        candidate.elected?,
        candidate.candidate_draw_affects_elected?,
        candidate.alliance_draw_affects_elected?,
        candidate.coalition_draw_affects_elected?
      ) + " " +
      formatted_candidate_name_with_dots(candidate.candidate_name) +
      formatted_candidate_number(candidate.candidate_number) + " " +
      formatted_alliance_shorten(candidate.electoral_alliance_shorten) +
      formatted_vote_sum(candidate.vote_sum) +
      formatted_draw_char(candidate.candidate_draw_identifier) +
      formatted_proportional_number(candidate.alliance_proportional) +
      formatted_draw_char(candidate.alliance_draw_identifier) +
      formatted_proportional_number(candidate.coalition_proportional) +
      formatted_draw_char(candidate.coalition_draw_identifier)
    ).html_safe # Otherwise double quotes will mess output
  end
  # rubocop:enable Rails/OutputSafety

  # RENKAAT________________________________________________________________ÄÄNET_PA
  #  6. Svenska Nationer och Ämnesföreningar (SNÄf)...................SNÄf  555  3
  def coalition_result_line(coalition_result, index)
    formatted_order_number(index + 1) + ". " +
      formatted_coalition_name_with_dots_and_shorten(
        coalition_result.electoral_coalition.name,
        coalition_result.electoral_coalition.shorten
      ) +
      formatted_vote_sum(coalition_result.vote_sum_cache) + " " +
      formatted_elected_candidates_count(
        elected_candidates_in_coalition(coalition_result).count
      )
  end

  # LIITOT__________________________________________________________RENGAS_ÄÄNET_PA
  #  24. SatO-ESO2............................................SatESO Osak    181  1
  def alliance_result_line(alliance_result, index)
    formatted_order_number(index + 1) + ". " +
      formatted_alliance_name_with_dots_and_shorten(
        alliance_result.electoral_alliance.name,
        alliance_result.electoral_alliance.shorten
      ) + " " +
      formatted_coalition_shorten(
        alliance_result.electoral_alliance.electoral_coalition.shorten
      ) +
      formatted_vote_sum(alliance_result.vote_sum_cache) + " " +
      formatted_elected_candidates_count(
        elected_candidates_in_alliance(alliance_result).count
      )
  end

  def formatted_order_number(number)
    format "%3d", number
  end

  def formatted_draw_char(identifier)
    format "%2.2s", identifier
  end

  def formatted_status_char(elected, effective_candidate_draw, effective_alliance_draw, effective_coalition_draw)
    unless final?
      return "=" if effective_coalition_draw
      return "~" if effective_alliance_draw
      return "?" if effective_candidate_draw
    end

    return "*" if elected

    "."
  end

  def formatted_elected_candidates_count(number)
    format "%2d", number.to_i
  end

  def formatted_candidate_number(number)
    format "%4d", number.to_i
  end

  def fill_dots(line_width, *contents)
    content_length = contents.map(&:length).sum
    dot_count = line_width - content_length
    dot_count = 0 if dot_count.negative?

    '.' * dot_count
  end

  def formatted_coalition_shorten(shorten)
    format "%-6.6s", shorten
  end

  def formatted_alliance_name_with_dots_and_shorten(name, shorten)
    line_width = 58
    truncated_name = name.slice(0, 52)
    truncated_shorten = shorten.slice(0, 6)

    format(
      "%.52<name>s%<dots>s.%.6<shorten>s",
      name: truncated_name,
      dots: fill_dots(line_width, truncated_name, truncated_shorten),
      shorten: truncated_shorten
    )
  end

  def formatted_coalition_name_with_dots_and_shorten(name, shorten)
    line_width = 66
    truncated_shorten = shorten.slice(0, 6)
    truncated_name = name.slice(0, 52)

    format(
      "%.52<name>s%<dots>s%.6<shorten>s",
      name: truncated_name,
      dots: fill_dots(line_width, truncated_name, truncated_shorten),
      shorten: truncated_shorten
    )
  end

  def formatted_candidate_name_with_dots(candidate_name)
    line_width = 30
    truncated_name = candidate_name.slice(0, line_width)

    format(
      "%.#{line_width}<name>s%<dots>s",
      name: truncated_name,
      dots: fill_dots(line_width, truncated_name)
    )
  end

  def formatted_alliance_shorten(shorten)
    format "%6.6s", shorten
  end

  def formatted_vote_sum(number)
    format "%5s", number
  end

  def formatted_proportional_number(number)
    precision = Vaalit::Voting::PROPORTIONAL_PRECISION
    format "%11.#{precision}f", number.to_f
  end
end
