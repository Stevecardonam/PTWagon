import { Task } from 'src/tasks/entities/task.entity';
import {
  Column,
  DeleteDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('varchar', {
    length: 50,
  })
  name: string;

  @Column('varchar', {
    length: 50,
  })
  lastName: string;

  @Column('varchar', {
    length: 50,
    unique: true,
  })
  email: string;

  @Column('varchar', {
    length: 70,
  })
  password: string;

  @Column('bigint', {
    nullable: true,
  })
  phone: number;

  @Column('varchar', {
    nullable: true,
    length: 50,
  })
  country: string;

  @Column('text', {
    nullable: true,
  })
  address: string;

  @Column('varchar', {
    nullable: true,
    length: 50,
  })
  city: string;

  @DeleteDateColumn()
  deletedAt: Date;

  @OneToMany(() => Task, (task) => task.user)
  tasks: Task[];
}
