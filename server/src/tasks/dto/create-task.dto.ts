import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateTaskDto {
  @Transform(({ value }) =>
    typeof value === 'string' ? value.toLowerCase() : value,
  )
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(80)
  title: string;

  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  description: string;
}
