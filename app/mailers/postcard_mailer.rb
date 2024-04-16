class PostcardMailer < ApplicationMailer
    def sample(user)
      @user = user
      mail(to: user.email, subject: "PostCard Mail Test")
    end
end