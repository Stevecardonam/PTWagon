import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task } from './entities/task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { User } from 'src/users/entities/user.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
  ) {}

  async create(createTaskDto: CreateTaskDto, user: User): Promise<Task> {
    const { title } = createTaskDto;

    const existing = await this.taskRepository.findOne({
      where: { title, user: { id: user.id } },
    });

    if (existing) {
      throw new BadRequestException('You already have a task with this title');
    }

    const newTask = this.taskRepository.create({ ...createTaskDto, user });
    return this.taskRepository.save(newTask);
  }

  async findAll(user: User): Promise<Task[]> {
    return this.taskRepository.find({
      where: { user: { id: user.id } },
    });
  }

  async findOne(id: string, user: User): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id, user: { id: user.id } },
    });

    if (!task) {
      throw new NotFoundException(`Task with id ${id} not found`);
    }

    return task;
  }

  async update(
    id: string,
    updateTaskDto: UpdateTaskDto,
    user: User,
  ): Promise<Task> {
    const task = await this.findOne(id, user);

    const { title } = updateTaskDto;

    if (title) {
      const existing = await this.taskRepository.findOne({
        where: { title, user: { id: user.id } },
      });

      if (existing && existing.id !== task.id) {
        throw new BadRequestException(
          'You already have a task with this title',
        );
      }
    }

    Object.assign(task, updateTaskDto);
    return this.taskRepository.save(task);
  }

  async remove(id: string, user: User): Promise<{ message: string }> {
    const task = await this.findOne(id, user);
    await this.taskRepository.remove(task);

    return { message: `Task with id ${id} deleted successfully` };
  }
}
