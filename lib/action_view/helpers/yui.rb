module ActionView
  module Helpers
    module YUI
      class Version
        class_inheritable_reader :major, :minor, :tiny
        write_inheritable_attribute :major, 2
        write_inheritable_attribute :minor, 5
        write_inheritable_attribute :tiny,  1

        def to_s
          "#{major}.#{minor}.#{tiny}"
        end
      end

      VERSION = Version.new
    end
  end
end
