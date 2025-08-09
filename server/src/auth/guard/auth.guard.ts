import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { Observable } from 'rxjs';

interface JwtPayload {
  sub: string;
  email?: string;
  iat: number;
  exp: number;
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const req: Request = context.switchToHttp().getRequest();

    const authHeader = req.headers.authorization;

    if (!authHeader)
      throw new UnauthorizedException('Authorization header missing');

    const token = authHeader.split(' ')[1];

    if (!token) throw new UnauthorizedException('Token not found');

    try {
      const secret = process.env.JWT_SECRET;
      if (!secret) {
        throw new Error('JWT_SECRET is not defined');
      }

      const payload = this.jwtService.verify<JwtPayload>(token, { secret });

      req.user = {
        ...payload,
        exp: new Date(payload.exp * 1000),
        iat: new Date(payload.iat * 1000),
      };
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }

    return true;
  }
}
