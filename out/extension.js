"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = require("vscode");
const path = require("path");
function activate(context) {
    const startCommand = vscode.commands.registerCommand('context7.start', () => {
        // No-op; activation registers the MCP server definition provider.
    });
    context.subscriptions.push(startCommand);
    // Register Context7 MCP Server
    context.subscriptions.push(vscode.lm.registerMcpServerDefinitionProvider('context7', {
        provideMcpServerDefinitions() {
            return [
                new vscode.McpStdioServerDefinition('context7', 'node', [
                    path.join(__dirname, '..', 'node_modules', '@upstash', 'context7-mcp', 'dist', 'index.js'),
                ])
            ];
        }
    }));
}
// This method is called when your extension is deactivated
function deactivate() { }
//# sourceMappingURL=extension.js.map