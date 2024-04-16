class PostcardMailController
    def send_mail(user)
        PostcardMailer.sample(user).deliver_now
    end
end