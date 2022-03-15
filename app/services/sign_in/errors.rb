# frozen_string_literal: true

module SignIn
  module Errors
    ERROR_CODES = {
      unknown: '007'
    }.freeze

    class RefreshVersionMismatchError < StandardError; end
    class RefreshNonceMismatchError < StandardError; end
    class RefreshTokenMalformedError < StandardError; end
    class AccessTokenSignatureMismatchError < StandardError; end
    class AccessTokenMalformedJWTError < StandardError; end
    class AccessTokenExpiredError < StandardError; end
    class AntiCSRFMismatchError < StandardError; end
    class SessionNotAuthorizedError < StandardError; end
    class TokenTheftDetectedError < StandardError; end
    class MalformedParamsError < StandardError; end
    class CodeChallengeMethodMismatchError < StandardError; end
    class CodeChallengeMismatchError < StandardError; end
    class CodeChallengeMalformedError < StandardError; end
    class GrantTypeValueError < StandardError; end
    class CodeInvalidError < StandardError; end
    class TokenSessionMismatch < StandardError; end
    class AuthorizeInvalidType < StandardError; end
    class CallbackInvalidType < StandardError; end
    class StateMismatchError < StandardError; end
    class CodeVerifierMalformedError < StandardError; end
    class UserAccountNotFound < StandardError; end
    class UserAttributesMalformedError < StandardError; end
  end
end
