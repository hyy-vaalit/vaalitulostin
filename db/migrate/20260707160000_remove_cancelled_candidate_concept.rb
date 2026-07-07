class RemoveCancelledCandidateConcept < ActiveRecord::Migration[8.0]
  # Candidate cancellation happens before voting starts and lives in the
  # ehdokastiedot repository; these flags were never set in this system.
  # Their only runtime effect was a hazard: alliance/coalition sums
  # included all candidates while candidate listings filtered through
  # votable, so a flag set by accident would silently desync the
  # proportionals from the candidate rows (P2.8).
  def change
    remove_column :candidates, :cancelled, :boolean, default: false
    remove_column :candidates, :marked_invalid, :boolean, default: false
  end
end
