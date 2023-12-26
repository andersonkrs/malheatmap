class ErrorSubscriber
  def report(error, severity:, context:, **_args)
    Rollbar.log(severity.to_s, error, **context)
  end
end

Rails.error.subscribe(ErrorSubscriber.new)
