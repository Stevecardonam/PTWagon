import { PickType } from '@nestjs/mapped-types';
import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsEmail,
  MinLength,
  MaxLength,
  Matches,
  IsNotEmpty,
  IsNumber,
  IsOptional,
} from 'class-validator';

export class CreateUserDto {
  @ApiProperty({ example: 'John' })
  @IsNotEmpty()
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(80)
  name: string;

  @ApiProperty({ example: 'Perez' })
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(80)
  lastName: string;

  @ApiProperty({ example: 'John@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: 'Password1!' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&.*]).{8,15}$/, {
    message:
      'Password must include upper/lowercase letters, a number, a special character (!@#$%^&*), and be 8-15 characters long',
  })
  @IsString()
  @MinLength(8)
  @MaxLength(15)
  password: string;

  @ApiProperty({ example: '1234567890' })
  @IsNumber()
  @IsOptional()
  phone?: number;

  @ApiProperty({ example: 'United States' })
  @IsString()
  @IsOptional()
  @MinLength(5)
  @MaxLength(20)
  country?: string;

  @ApiProperty({ example: '123 Main Street' })
  @IsString()
  @IsOptional()
  @MinLength(3)
  @MaxLength(80)
  address?: string;

  @ApiProperty({ example: 'New York' })
  @IsString()
  @IsOptional()
  @MinLength(5)
  @MaxLength(20)
  city?: string;
}

export class LoginDto extends PickType(CreateUserDto, ['email', 'password']) {}