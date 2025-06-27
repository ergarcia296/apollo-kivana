// === Inicializa Elastic APM ANTES de todo ===
import apm from 'elastic-apm-node';
apm.start({
  serviceName: 'apollo-server',
  serverUrl: 'http://localhost:8200',
  environment: 'development',
  logLevel: 'debug',
});

// === Resto de imports ===
import express from 'express';
import http from 'http';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { ApolloServerPluginLandingPageLocalDefault } from '@apollo/server/plugin/landingPage/default';
import cors from 'cors';

// === GraphQL schema y resolvers ===
const typeDefs = `#graphql
  type Book { title: String author: String }
  type Query { books: [Book] }
`;

const books = [
  { title: 'The Awakening', author: 'Kate Chopin' },
  { title: 'City of Glass', author: 'Paul Auster' },
];

const resolvers = {
  Query: {
    books: async (_, __, { req }) => {
      // Este span ahora sí será hijo de la transacción HTTP creada por Elastic APM
      const transaction = apm.startTransaction('GraphQL Query - books', 'request');
      const span = apm.startSpan('books resolver');
      try {
        return books;
      } finally {
        if (span) span.end();
        if (transaction) transaction.end();
      }
    },
  },
};

async function main() {
  const app = express();
  const httpServer = http.createServer(app);

  // Inicializa Apollo Server
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    plugins: [ApolloServerPluginLandingPageLocalDefault()],
  });
  await server.start();

  app.use(cors());
  app.use(express.json());
  app.use('/graphql', expressMiddleware(server, {
    context: async ({ req }) => ({ req }),
  }));

  // Habilita el sandbox de Apollo en la raíz para comodidad
  app.get('/', (_, res) => {
    res.send(`
      <!DOCTYPE html><html><head><meta charset="UTF-8"/>
      <title>Apollo Sandbox</title>
      <script src="https://unpkg.com/@apollo/embedded-browser@latest/dist/index.min.js"></script>
      </head><body style="margin:0">
      <apollo-embedded-browser endpoint-url="/graphql"></apollo-embedded-browser>
      </body></html>
    `);
  });

  await new Promise<void>(resolve => httpServer.listen({ port: 4000 }, resolve));
  console.log('🚀 Server ready at http://localhost:4000/');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});