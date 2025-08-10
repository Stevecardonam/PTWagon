import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { CreateUserDto, LoginDto } from 'src/users/dto/create-user.dto';
import { User } from 'src/users/entities/user.entity';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User) private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async signUp(user: CreateUserDto) {
    const { ...userData } = user;

    const findUser = await this.userRepository.findOneBy({
      email: userData.email,
    });

    if (findUser) {
      throw new ConflictException('User already exists');
    }

    const hashedPassword = await bcrypt.hash(user.password, 10);

    const newUser = this.userRepository.create({
      ...userData,
      password: hashedPassword,
    });

    const savedUser = await this.userRepository.save(newUser);

    const payload = {
      id: savedUser.id,
      email: savedUser.email,
    };

    const token = this.jwtService.sign(payload);
    const { password: _, ...cleanUser } = savedUser;

    return { user: cleanUser, access_token: token };
  }

  async signIn(credentials: LoginDto) {
    const { email, password } = credentials;

    const findUser = await this.userRepository.findOneBy({ email });
    if (!findUser) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(password, findUser.password);
    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid Credentials');
    }

    const payload = {
      id: findUser.id,
      email: findUser.email,
    };

    const token = this.jwtService.sign(payload);
    return { access_token: token };
  }
}
