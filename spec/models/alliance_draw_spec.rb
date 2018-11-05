describe AllianceDraw do
  subject(:draw) { described_class.new }

  it 'defines an identifier range character' do
    draw.identifier_number = 0
    expect(draw.identifier).to eq 'a'

    draw.identifier_number = 1
    expect(draw.identifier).to eq 'b'

    draw.identifier_number = 26
    expect(draw.identifier).to eq 'aa'

    draw.identifier_number = 18277
    expect(draw.identifier).to eq 'zzz'
  end
end
