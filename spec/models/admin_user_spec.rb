describe AdminUser do
  subject(:user) { described_class.new }

  it "generates password after creation" do
    expect(user.encrypted_password).to eq ""
    user.save validation: false

    expect(user.encrypted_password).not_to eq ""
  end
end
