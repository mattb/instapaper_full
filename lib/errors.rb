module InstapaperFull
  class API
    class Error < RuntimeError

      attr_reader :code, :message

      def initialize(code, message)
        @code, @message = code, message
      end

    end
  end
end
