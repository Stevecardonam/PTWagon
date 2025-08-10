import { DataSource, DataSourceOptions } from 'typeorm';
import { registerAs } from '@nestjs/config';
import { config as dotenvconfig } from 'dotenv';

dotenvconfig({ path: '.env.development' });

const config = {
  type: 'postgres' as const,
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'postgres',
  entities: ['dist/**/*.entity.js'],
  migrations: ['dist/migrations/*.js'],
  synchronize: true,
  logging: false,
  autoLoadEntities: true,
  dropSchema: false,
};
export default registerAs('typeorm', () => config);

export const connectionSource = new DataSource(config as DataSourceOptions);

// Configuracion para deploy en render:

// import { DataSource, DataSourceOptions } from 'typeorm';
// import { registerAs } from '@nestjs/config';

// const config = {
//   type: 'postgres' as const,
//   url: process.env.DATABASE_URL,
//   entities: ['dist/**/*.entity.js'],
//   migrations: ['dist/migrations/*.js'],
//   synchronize: true,
//   logging: false,
//   autoLoadEntities: true,
//   dropSchema: false,
//   ssl: {
//     rejectUnauthorized: false,
//   },
// };
// export default registerAs('typeorm', () => config);

// export const connectionSource = new DataSource(config as DataSourceOptions);
