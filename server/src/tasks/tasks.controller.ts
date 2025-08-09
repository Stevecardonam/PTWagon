import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  UseGuards,
  Put,
  Req,
  ParseUUIDPipe,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { JwtAuthGuard } from 'src/auth/guard/auth.guard';
import { Task } from './entities/task.entity';
import { User } from 'src/users/entities/user.entity';

@UseGuards(JwtAuthGuard)
@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post()
  create(
    @Body() createTaskDto: CreateTaskDto,
    @Req() req: Request & { user: User },
  ): Promise<Task> {
    return this.tasksService.create(createTaskDto, req.user);
  }

  @Get()
  findAll(@Req() req: Request & { user: User }): Promise<Task[]> {
    return this.tasksService.findAll(req.user);
  }

  @Get(':id')
  findOne(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Req() req: Request & { user: User },
  ): Promise<Task> {
    return this.tasksService.findOne(id, req.user);
  }

  @Put(':id')
  update(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() updateTaskDto: UpdateTaskDto,
    @Req() req: Request & { user: User },
  ): Promise<Task> {
    return this.tasksService.update(id, updateTaskDto, req.user);
  }

  @Delete(':id')
  remove(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Req() req: Request & { user: User },
  ) {
    return this.tasksService.remove(id, req.user);
  }
}
