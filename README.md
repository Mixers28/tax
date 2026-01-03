# Context7 MCP Server for VS Code

This VS Code extension integrates the Context7 MCP (Model Context Protocol) server to provide AI assistants with real-time access to current documentation for thousands of libraries and frameworks.

## Features

- **Real-time Documentation Access**: Provides AI models with access to current documentation for thousands of libraries and frameworks
- **Automatic Library Resolution**: Automatically finds and retrieves relevant documentation based on user queries
- **Up-to-date Content**: Always provides the latest documentation from official sources
- **Easy Integration**: Simple setup with no additional configuration required
- **Seamless VS Code Integration**: Works directly with VS Code's built-in AI features

## Installation

1. Clone this repository
2. Run `npm install` to install dependencies
3. Run `npm run compile` to build the extension
4. Press F5 in VS Code to launch the extension in a new Extension Development Host window

## Usage

The Context7 MCP server is automatically registered when the extension activates. It provides the following capabilities:

### Available Functions

1. **`mcp_context7-new_resolve-library-id`** - Resolves a package/product name to a Context7-compatible library ID
2. **`mcp_context7-new_get-library-docs`** - Fetches up-to-date documentation for a library

### Example Usage

When using an AI assistant in VS Code, you can now ask questions like:

- "Show me how to use React hooks use context7"
- "What are the best practices for Next.js routing? use context7"
- "How do I implement authentication with Supabase? use context7"
- "Give me examples of using TypeScript decorators use context7"
- "How do I set up a GraphQL server with Apollo? use context7"
- "What are the latest features in Node.js 20? use context7"

The Context7 MCP server will automatically:
1. Resolve the library name to the appropriate Context7 library ID
2. Fetch the latest documentation
3. Provide relevant code examples and documentation

### Direct Library Access

You can also directly specify library IDs in your prompts using the slash syntax:

```
"Implement basic authentication with Supabase. Use the API and documentation from the /supabase/supabase library."
```

## Configuration

### Extension Settings

The extension automatically registers the Context7 MCP server definition provider:

- **`context7`** - The Context7 MCP server for documentation access

### VS Code MCP Settings

The extension integrates with VS Code's built-in MCP support. No additional configuration is required in VS Code settings.

## Development

### Project Structure

```
├── src/
│   └── extension.ts          # Main extension code
├── package.json              # Extension manifest and dependencies
├── tsconfig.json            # TypeScript configuration
└── README.md               # This file
```

### Key Components

1. **Context7 Integration**: Uses `@upstash/context7-mcp` package to provide documentation access
2. **MCP Server Registration**: Registers MCP server definition providers using VS Code's proposed API

### Building

```bash
npm install    # Install dependencies
npm run compile # Build the extension
```

### Testing

1. Press F5 in VS Code to launch the extension in development mode
2. Use an AI assistant to test Context7 functionality
3. Try asking questions about various libraries and frameworks

## Context7 MCP Server Details

The Context7 MCP server provides access to documentation for thousands of libraries and frameworks. It supports:

- **Automatic Library Discovery**: Finds relevant libraries based on user queries
- **Real-time Documentation**: Always provides the latest documentation
- **Code Examples**: Includes practical code snippets and examples
- **Multiple Languages**: Supports documentation in various programming languages

### Supported Libraries

Context7 provides documentation for popular libraries and frameworks including:

- **Frontend**: React, Next.js, Vue.js, Angular, Svelte
- **Backend**: Node.js, Express, Fastify, NestJS
- **Python**: Django, Flask, FastAPI, Pandas, NumPy
- **Database**: Prisma, TypeORM, Mongoose, Sequelize
- **Cloud**: AWS, Google Cloud, Azure, Vercel, Netlify
- **AI/ML**: TensorFlow, PyTorch, Scikit-learn, OpenAI
- **And thousands more...**

## Benefits

### For Developers
- **Enhanced AI Assistance**: Get accurate, up-to-date documentation in AI responses
- **Reduced Context Switching**: No need to search documentation separately
- **Better Code Quality**: Access to best practices and examples
- **Faster Development**: Quick answers to library-specific questions

### For Teams
- **Consistent Information**: Everyone gets the same, current documentation
- **Reduced Training Time**: New team members can ask AI for library help
- **Better Code Reviews**: AI can reference current best practices

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Acknowledgments

- [Context7](https://context7.com) for providing the MCP server for real-time documentation access