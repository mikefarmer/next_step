module NextStep
  module Payload

    attr_reader :payload

    def set_initial_payload(initial_payload)
      @payload = initial_payload
      on_advance do |r|
        r.payload = payload
      end
    end


    def final_payload
      @payload
    end



  end
end
