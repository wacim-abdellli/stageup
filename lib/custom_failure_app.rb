# frozen_string_literal: true

class CustomFailureApp < Devise::FailureApp
  def respond
    if request_format == :turbo_stream
      redirect
    else
      super
    end
  end

  def skip_format?
    %i[html turbo_stream].include?(request_format)
  end
end
