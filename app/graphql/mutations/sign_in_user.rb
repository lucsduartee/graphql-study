module Mutations
  class SignInUser < BaseMutation
    null true

    argument :credentials, Types::AuthProviderCredentialsInput, required: false

    field :token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(credentials:)
      # put some validations here

      return unless credentials
      p "credentials", credentials[:email]
      user = User.find_by email: credentials[:email]
      return unless user
      return unless user.authenticate(credentials[:password])

      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base.byteslice(0..31))
      token = crypt.encrypt_and_sign("user-id:#{ user.id }")

      context[:session][:token] = token

      { user: user, token: token }
    end
  end
end
