require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "password_reset" do
    # Userを作成する
    let(:user) { create(:user) }
    # そのUserにハッシュ化したトークンをDBに保存する
    before { user.create_reset_digest }
    # UserMailerクラスにuserの情報を持たせ、password_resetアクションを実行する
    subject { UserMailer.with(user: user).password_reset }

    it "宛先が正しい" do
      # UserMailerクラスのto（宛先）とDBのメールアドレスが一致するか
      expect(subject.to).to eq([ user.email_address ])
    end

    it "件名が正しい" do
      expect(subject.subject).to eq("パスワードの再設定")
    end

    it "本文にリセット用のURLが含まれる(html)" do
      # HTML版のビューがレンダリングされた「実際の本文」の中に、生のトークンが含まれているか確認
      expect(subject.html_part.body.decoded).to include(user.reset_token)
    end
    it "本文にリセット用のURLが含まれる(テキスト)" do
      # テキスト版のビューがレンダリングされた「実際の本文」の中に、生のトークンが含まれているか確認
      expect(subject.text_part.body.decoded).to include(user.reset_token)
    end
  end
end
