import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async findOne(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with id ${id} not found`);
    }
    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const userToUpdate = await this.findOne(id);
    if (updateUserDto.email && updateUserDto.email !== userToUpdate.email) {
      const existingEmail = await this.userRepository.findOne({
        where: { email: updateUserDto.email },
      });
      if (existingEmail) {
        throw new ConflictException(
          `Email ${updateUserDto.email} already in use`,
        );
      }
    }

    if (updateUserDto.password) {
      const hashedPassword = await bcrypt.hash(updateUserDto.password, 10);
      userToUpdate.password = hashedPassword;
    }

    const updatedUser = Object.assign(userToUpdate, updateUserDto);

    try {
      return await this.userRepository.save(updatedUser);
    } catch (error) {
      throw new ConflictException(`Could not update user: ${error}`);
    }
  }

  async remove(id: string): Promise<void> {
    const userToDelete = await this.findOne(id);
    try {
      await this.userRepository.softRemove(userToDelete);
    } catch (error) {
      throw new NotFoundException(
        `Could not soft-delete user with id ${id}: ${error}`,
      );
    }
  }
}
