# local-mcp-context-kit

A lightweight, editor-friendly framework for using **plain Markdown files + Git** as persistent “project memory” for human + AI collaboration.

No cloud services. No servers. Just **files, Git, and a consistent start/end session ritual**.

## What this kit provides
- Long-term memory: `docs/PROJECT_CONTEXT.md`
- Working memory: `docs/NOW.md`
- Session log: `docs/SESSION_NOTES.md`
- Agent protocol: `docs/AGENT_SESSION_PROTOCOL.md`
- Design notes: `docs/MCP_LOCAL_DESIGN.md`

## Getting started
### 1) Clone
```bash
git clone https://github.com/YOUR_USERNAME/local-mcp-context-kit
cd local-mcp-context-kit
```

### 2) Install the CLI
```bash
python -m pip install -e .
```

### 3) Fill in your project details
- Edit `docs/PROJECT_CONTEXT.md` and `docs/NOW.md`.
- Let your agent maintain any summary blocks.

### 4) Start a session
In VS Code: `Tasks: Run Task` → `Start Session (Agent - Coder)` (or pick another role)

Or run directly:
```bash
handoffkit session start --agent-role Coder --open-docs
```

### 5) End a session (writeback + commit/push)
In VS Code: `Tasks: Run Task` → `End Session (Agent + Commit)`

Or run directly:
```bash
handoffkit session end --commit
```

## Tooling
- VS Code tasks: `.vscode/tasks.json`
- CLI: `handoffkit` (session start/end + role handoff prompts)

## License
MIT

Added PROJECT_CONTEXT, NOW, SESSION_NOTES (LTM/WM/SM)

Added AGENT_SESSION_PROTOCOL and MCP_LOCAL_DESIGN docs

Added handoffkit CLI and VS Code tasks for start/end session

Ready for public release
