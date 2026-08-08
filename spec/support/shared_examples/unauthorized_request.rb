RSpec.shared_examples "未ログインだと401が返る" do
  it "未ログインだと401が返る" do
    subject
    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.shared_examples "未ログインだと200が返る" do
  it "未ログインだと200が返る" do
    subject
    expect(response).to have_http_status(:success)
  end
end

RSpec.shared_examples "成功する" do |status|
  it "#{status}が返る" do
    subject
    expect(response).to have_http_status(status)
  end
end
