# Pre-assignment for Reaktor Summer 2021

## Demos: frontend [warehouse.luukuton.fi](https://warehouse.luukuton.fi) & backend [ware-api.luukuton.fi](https://ware-api.luukuton.fi)

Backend has to be set up first! Otherwise the frontend won't build as it's server-side-rendered.

## Backend

A really simple local backend to make more sense of the [**Bad** API](https://bad-api-assignment.reaktor.com/). Made with Ruby.

The default port of the backend can be changed in [backend.rb](backend/backend.rb) by changing line: `set :port, 4755`,

### Installation & Usage

1. `cd backend`
2. Install dependencies `bundle install`
3. Start with: `ruby backend.rb`

Running backend the first time can take up to 1-2 minutes depending on the connection and the amount of Bad API's _built-in intentional failures_.

### Dependencies

- Ruby 3.0+ (should work with Ruby 2.x as well)
- Other web servers such as [Puma](https://github.com/puma/puma) work as well (default [Webrick](https://github.com/ruby/webrick))

## Frontend

A server-side-rendered frontend made with Next.js.

The default backend URL can be changed in [.env.local](frontend/.env.local).

### Installation & Usage

1. `cd frontend`
2. Install dependencies: `npm install --force`
3. Start with: `npm run build` & `npm run start` or just `npm run dev` for the development mode

### Dependencies

- nodejs v14.16.0+ (LTS)
- npm latest (tested with 7.4.2)

## Something to improve 

- Improve or change [VirtualScroller](https://www.npmjs.com/package/virtual-scroller) to something faster
- More precise internal caching!
