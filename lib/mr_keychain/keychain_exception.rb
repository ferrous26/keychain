module Keychain

# A trivial exception class that exists to help differentiate where
# exceptions are being raised.
class KeychainException < Exception

  # @param [#to_s] message_prefix meant to be an indicator of where the
  #  exception originated from
  # @param [Fixnum] error_code the result code from calling a Sec function
  def initialize message_prefix, error_code
    cf_message = SecCopyErrorMessageString( error_code, nil )
    super "#{message_prefix}: #{cf_message}"
  end

end

end
