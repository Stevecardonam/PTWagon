import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { LoginDto } from '../users/dto/create-user.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signin')
  @HttpCode(HttpStatus.OK)
  signIn(@Body() credentials: LoginDto): Promise<{ access_token: string }> {
    return this.authService.signIn(credentials);
  }

  @Post('signup')
  @HttpCode(HttpStatus.CREATED)
  signUp(@Body() user: CreateUserDto): Promise<any> {
    return this.authService.signUp(user);
  }
}
