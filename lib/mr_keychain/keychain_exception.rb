##
# Properly extracts error messages based on error codes.
class Keychain::KeychainException < Exception

  # @return [Fixnum]
  attr_reader :code

  # @param [#to_s] message_prefix an indicator of where the exception originated
  # @param [Fixnum] error_code result code from calling a Sec function
  def initialize message_prefix, error_code
    cf_message = SecCopyErrorMessageString( error_code, nil )
    @code = error_code
    super "#{message_prefix}. [Error code: #{error_code}] #{cf_message}"
  end

end
