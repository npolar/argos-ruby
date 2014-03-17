module Argos
  class Exception < ::Exception
  end
  class SoapException < Exception
  end
  class NodataException < SoapException
  end
  class SoapFault < SoapException
  end
end