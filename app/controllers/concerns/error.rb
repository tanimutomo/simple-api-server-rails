# Errors
module Error
  class BadRequestError < StandardError; end
  class UnauthorizedError < StandardError; end
  class NotFoundError < StandardError; end
  class InternalServerError < StandardError; end
end
