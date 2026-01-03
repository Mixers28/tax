# Deployment Guide for Context7 VS Code Extension

This guide explains how to deploy the Context7 VS Code extension to the Visual Studio Code Marketplace.

## Prerequisites

1. **VS Code Extension Publisher Account**: You need a publisher account on the [Visual Studio Code Marketplace](https://marketplace.visualstudio.com/)
2. **vsce Tool**: Install the Visual Studio Code Extension Manager
3. **GitHub Account**: For hosting the source code

## Setup

### 1. Install vsce

```bash
npm install -g @vscode/vsce
```

### 2. Create a Publisher Account

1. Go to [Visual Studio Code Marketplace](https://marketplace.visualstudio.com/)
2. Sign in with your Microsoft account
3. Click "Publish extensions"
4. Create a new publisher account or use an existing one

### 3. Get a Personal Access Token

1. Go to [Azure DevOps](https://dev.azure.com/)
2. Create a new organization or use an existing one
3. Go to User Settings → Personal Access Tokens
4. Create a new token with "Marketplace (Publish)" scope
5. Copy the token (you'll need it for publishing)

## Publishing Steps

### 1. Update Extension Metadata

Before publishing, update the following in `package.json`:

```json
{
  "name": "context7-mcp",
  "displayName": "Context7 MCP Server",
  "description": "Real-time documentation access for AI assistants via Context7 MCP server",
  "version": "1.0.0",
  "publisher": "your-publisher-name",
  "private": false,
  "repository": {
    "type": "git",
    "url": "https://github.com/your-username/context7-vscode-extension.git"
  },
  "keywords": [
    "mcp",
    "context7",
    "documentation",
    "ai",
    "assistant"
  ],
  "categories": [
    "Other"
  ]
}
```

### 2. Build the Extension

```bash
npm install
npm run compile
```

### 3. Package the Extension

```bash
vsce package
```

This creates a `.vsix` file that you can install locally or publish.

### 4. Test Locally (Optional)

```bash
code --install-extension context7-mcp-1.0.0.vsix
```

### 5. Publish to Marketplace

```bash
vsce publish
```

You'll be prompted for:
- Your publisher name
- Your personal access token

## Publishing Options

### First Time Publishing

```bash
vsce publish --new
```

### Update Existing Extension

```bash
vsce publish patch  # 1.0.0 → 1.0.1
vsce publish minor  # 1.0.0 → 1.1.0
vsce publish major  # 1.0.0 → 2.0.0
```

## Marketplace Listing

### Extension Icon

Create a 128x128 pixel icon and save it as `icon.png` in the root directory.

### README for Marketplace

The `README.md` file will be used as the marketplace description. Make sure it includes:

- Clear description of features
- Installation instructions
- Usage examples
- Screenshots (if applicable)

### Marketplace Categories

Choose appropriate categories in `package.json`:

```json
"categories": [
  "Other",
  "Programming Languages",
  "Snippets"
]
```

## Continuous Integration

### GitHub Actions

Create `.github/workflows/publish.yml`:

```yaml
name: Publish Extension

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install
      - run: npm run compile
      - run: npm install -g @vscode/vsce
      - run: vsce publish
        env:
          VSCE_PAT: ${{ secrets.VSCE_PAT }}
```

### Secrets

Add your personal access token as a GitHub secret named `VSCE_PAT`.

## Version Management

### Semantic Versioning

Follow semantic versioning:
- **Patch** (1.0.1): Bug fixes
- **Minor** (1.1.0): New features, backward compatible
- **Major** (2.0.0): Breaking changes

### Changelog

Maintain a `CHANGELOG.md` file:

```markdown
# Changelog

## [1.0.0] - 2024-01-01
### Added
- Initial release
- Context7 MCP server integration
- Real-time documentation access for AI assistants

## [1.0.1] - 2024-01-15
### Fixed
- Fixed TypeScript compilation issues
```

## Post-Publishing

### Monitor Usage

- Check the extension's marketplace page for reviews and ratings
- Monitor download statistics
- Respond to user feedback and issues

### Updates

- Regularly update the Context7 MCP dependency
- Add new features based on user feedback
- Fix bugs and improve performance

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Ensure your personal access token is valid and has the correct permissions
2. **Package Errors**: Make sure all dependencies are properly installed
3. **Compilation Errors**: Check TypeScript compilation before packaging

### Support

- Create issues on GitHub for bugs and feature requests
- Respond to marketplace reviews
- Maintain documentation and examples

## Legal Considerations

- Ensure you have the right to publish the extension
- Include appropriate licenses for all dependencies
- Respect Context7's terms of service
- Include privacy policy if collecting user data

## Resources

- [VS Code Extension Publishing Guide](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)
- [vsce Documentation](https://github.com/microsoft/vscode-vsce)
- [Marketplace Publisher Guide](https://docs.microsoft.com/en-us/azure/devops/extend/publish/overview) 