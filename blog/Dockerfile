FROM node:10-alpine as builder

WORKDIR /app

COPY package.json yarn.lock ./
COPY packages/ packages/
COPY posts/ posts/

RUN yarn install --frozen-lockfile
RUN yarn --cwd packages/client build
RUN ln -s /app/packages/client/build /app/packages/server/public

ENV NODE_ENV production
RUN yarn install --frozen-lockfile --production
RUN yarn cache clean

EXPOSE 5678
CMD ["yarn", "--cwd", "packages/server", "start"]
