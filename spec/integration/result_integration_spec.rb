RSpec.describe Result, type: :integration do
  let(:s3_publisher) { instance_double S3Publisher }
  let(:comparer) { Comparison::Year2009.new }
  let(:comparison_votes) { comparer.final_votes }
  let(:all_candidates) { Candidate.all.order('candidate_number asc') }

  before do
    Seed::Year2009.import_base_data!

    allow(S3Publisher).to receive(:new).and_return(s3_publisher)
    # allow(s3_publisher).to receive(:store_to_s3!)
  end

  context 'when first result is created after all votes are submitted' do
    let!(:subject) { Result.freeze_for_draws! } # calculates proportionals

    it 'calculates correct candidate proportionals' do
      proportionals = comparer.proportionals

      all_candidates.each_with_index do |candidate, index|
        csv_row = proportionals[index]

        expect(candidate.candidate_number)
          .to eq csv_row['candidate_number'].to_i

        expect(candidate.coalition_proportionals.first.number)
          .to eq csv_row['coalition_proportional'].to_f

        expect(candidate.alliance_proportionals.first.number)
          .to eq csv_row['alliance_proportional'].to_f
      end
    end

    it 'has equivalent vote sums and candidate draws than 2009 data' do
      final_votes = comparer.final_votes
      all_candidates.each_with_index do |candidate, index|
        csv_row = final_votes[index]
        db_row = candidate.candidate_results.first

        expect(candidate.candidate_number)
          .to eq csv_row['candidate_number'].to_i

        expect(db_row.vote_sum_cache)
          .to eq csv_row['votes'].to_i

        if csv_row['candidate_draw_order'].to_i.nonzero?
          expect(db_row.candidate_draw_id).to be_present
        end
      end
    end
  end

  context 'when candidate draw order has been determined' do
    let!(:result) { Result.freeze_for_draws! } # calculates proportionals

    before do
      Seed::Year2009.import_candidate_draw_order!
    end

    it 'calculates equivalent alliance draws than 2009 data' do
      expect(result.candidate_draws_ready!).to eq result

      final_votes = comparer.final_votes
      all_candidates.each_with_index do |candidate, index|
        csv_row = final_votes[index]
        db_row = candidate.candidate_results.first

        expect(candidate.candidate_number)
          .to eq csv_row['candidate_number'].to_i

        if csv_row['alliance_draw_order'].to_i.nonzero?
          expect(db_row.alliance_draw_id).to be_present
        end
      end
    end
  end

  context 'when alliance draw order has been determined' do
    let!(:result) { Result.freeze_for_draws! } # calculates proportionals

    before do
      Seed::Year2009.import_candidate_draw_order!
      result.candidate_draws_ready!
      Seed::Year2009.import_alliance_draw_order!
    end

    it 'calculates equivalent alliance draws than 2009 data' do
      expect(result.alliance_draws_ready!).to eq result

      all_candidates.each_with_index do |candidate, index|
        csv_row = comparison_votes[index]
        db_row = candidate.candidate_results.first

        expect(candidate.candidate_number)
          .to eq csv_row['candidate_number'].to_i

        if csv_row['coalition_draw_order'].to_i.nonzero?
          expect(db_row.coalition_draw_id).to be_present
        end
      end
    end
  end

  context 'when final result can be calculated' do
    let!(:result) { Result.freeze_for_draws! } # calculates proportionals

    let(:dir) { File.join __dir__, 'expected_after_draws' }
    let(:result_html) { File.read File.join(dir, 'result.html') }
    let(:result_json) { File.read File.join(dir, 'result.json') }
    let(:candidates) { File.read File.join(dir, 'candidates.json') }

    before do
      Seed::Year2009.import_candidate_draw_order!
      result.candidate_draws_ready!
      Seed::Year2009.import_alliance_draw_order!
      result.alliance_draws_ready!
    end

    it 'calculates equivalent coalition draws than 2009 data' do
      expect(result.finalize!).to eq result

      all_candidates.each_with_index do |candidate, index|
        csv_row = comparison_votes[index]
        db_row = candidate.candidate_results.first

        expect(candidate.candidate_number)
          .to eq csv_row['candidate_number'].to_i

        if csv_row['coalition_draw_order'].to_i.nonzero?
          expect(db_row.coalition_draw_id).to be_present
        end
      end
    end

    fit 'renders the final result' do
      puts "Start: #{Time.now}"
      result.finalize!
      puts "End: #{Time.now}"

      decorator = ResultDecorator.decorate result

      expect(decorator.to_html).to eq result_html
      # expect(decorator.to_json).to include_json JSON.parse(result_json)
      # expect(decorator.to_json_candidates).to include_json(JSON.parse(candidates))
    end
  end
end
