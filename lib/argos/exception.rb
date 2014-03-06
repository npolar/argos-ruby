module Argos
  class Exception < ::Exception
  end
  class SoapException < Exception
  end
  class SoapFault < SoapException
  end
end