class PostcardMailController
    ##
    # The function `send_mail` in Ruby sends a sample postcard mail to a user using the
    # `PostcardMailer` with immediate delivery.
    # 
    # Args:
    #   user: The `send_mail` method takes a `user` parameter, which is likely an object representing
    # a user to whom the email will be sent. This user object may contain information such as the
    # user's email address, name, or any other relevant details needed to send the email.
    def send_mail(user)
        postcard = PostcardMailer.with(user: user).postcard  
        postcard.deliver_now
    end
end