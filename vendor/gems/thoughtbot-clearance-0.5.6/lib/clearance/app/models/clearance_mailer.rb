module Clearance
  module App
    module Models
      module ClearanceMailer

        def change_password(user)
          from       DO_NOT_REPLY
          recipients user.email
          subject    "Reset your PYO (Put Yourself On) Password"
          body       :user => user
        end

        def confirmation(user)
          from       DO_NOT_REPLY
          recipients user.email
          subject   "PYO (Put Yourself On) Account Confirmation"
          body      :user => user
        end

      end
    end
  end
end
