const { AppError } = require('./errorHandler');

exports.validateRequest = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body, { abortEarly: false });
    
    if (error) {
      const errorMessage = error.details.map(detail => detail.message).join(', ');
      return next(new AppError(`Validation Error: ${errorMessage}`, 400));
    }
    
    next();
  };
};
