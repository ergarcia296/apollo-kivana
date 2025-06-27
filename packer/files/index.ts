import apm from 'elastic-apm-node';
apm.start({
  serviceName: 'apollo-server',
  serverUrl: 'http://localhost:8200',
  environment: 'development',
  logLevel: 'debug',
});

import express from 'express';
import http from 'http';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import cors from 'cors';

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
    books: async () => {
      const span = apm.startSpan('books resolver');
      try { return books; }
      finally { if (span) span.end(); }
    },
  },
};

async function main() {
  const app = express();
  const httpServer = http.createServer(app);
  const server = new ApolloServer({ typeDefs, resolvers });
  await server.start();

  app.use('/graphql', cors(), express.json(), expressMiddleware(server));
  app.get('/', (_, res) => res.redirect('/graphql'));

  await new Promise<void>(resolve => httpServer.listen({ port: 4000 }, resolve));
  console.log('🚀 Server ready at http://localhost:4000/graphql');
}

main().catch(console.error);