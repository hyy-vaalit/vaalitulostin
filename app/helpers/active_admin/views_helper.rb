# N.B. You need to restart Rails Server before changes are applied!

module ActiveAdmin::ViewsHelper
  # Candidate view is shared with ActiveAdmin and Advocates.
  def link_to_edit_candidate(scope, candidate)
    if scope == "admin"
      edit_admin_candidate_path(candidate)
    else
      edit_advocates_alliance_candidate_path(candidate.electoral_alliance, candidate)
    end
  end
end