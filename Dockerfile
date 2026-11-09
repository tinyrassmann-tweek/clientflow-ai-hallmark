FROM node:24-alpine
WORKDIR /app
COPY package.json ./
COPY src ./src
COPY scripts ./scripts
COPY public ./public
ENV NODE_ENV=production
ENV PORT=8080
USER node
EXPOSE 8080
CMD ["node","scripts/server.mjs"]
