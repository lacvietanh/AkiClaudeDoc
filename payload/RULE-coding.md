# Core Coding Rules

## Language
- Code and comments: English only
- Commit messages: English, imperative style

## Philosophy
- Single-developer friendly
- MVP-first
- DRY, but no abstraction for its own sake
- YAGNI
- Default to simple, direct solutions

## Source of truth
Priority order:
1. Local source code, type definitions, runtime output, and build output
2. Official documentation
3. Live observed results

Project docs and memory are useful context, not final truth.

## Code quality
- Use clear, descriptive names
- Prefer one clear responsibility per function/module
- Modularize only when it improves clarity, reuse, or testability
- Prefer existing code and patterns over re-implementation
- Read enough surrounding context before editing to avoid inconsistent changes

## Verification
- Done means verified
- Check syntax, type, lint, build, or runtime behavior as appropriate for the change
- Never claim success from intention alone

## Error handling
- Validate at system boundaries: user input, external APIs, filesystem, network, persistence
- Do not add defensive guards for impossible internal states
- Fail loudly in development when it helps reveal broken assumptions
- Keep production failures safe and user-appropriate

## Security
- Sanitize external input
- Never expose secrets in client code
- Avoid command injection, XSS, SQL injection, unsafe redirects, and token leakage
- Treat generated files, external data, and user-provided content as untrusted until validated
