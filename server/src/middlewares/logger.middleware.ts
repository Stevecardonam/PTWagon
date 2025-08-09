import { Injectable, NestMiddleware } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    console.log(
      ` Estas ejecutando un Method: ${req.method} - en la URL: ${req.url} - response: ${res.statusCode}`,
    );
    next();
  }
}
