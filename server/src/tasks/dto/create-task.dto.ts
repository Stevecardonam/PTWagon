import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateTaskDto {
  @ApiProperty({ example: 'Buy groceries' })
  @IsNotEmpty()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.toLowerCase() : value,
  )
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(80)
  title: string;

  @ApiProperty({ example: 'Buy bread, milk, and eggs' })
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  description: string;
}
