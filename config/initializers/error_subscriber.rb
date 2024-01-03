class ErrorSubscriber
  def report(error, severity:, context:, **_args)
    Rollbar.log(severity.to_s, error, use_exception_level_filters: true, **context)
  end
end

Rails.error.subscribe(ErrorSubscriber.new)
