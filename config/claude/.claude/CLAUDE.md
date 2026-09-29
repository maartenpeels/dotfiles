# Global Instructions

## Code comments

Write a comment only when deleting it would lose information the code doesn't show:
a non-obvious *why*, a magic value, a workaround, or a gotcha. Never write comments that:

- restate what the next line does (`// Only assigned users get a token` above `appRoleAssignmentRequired: true`);
- point at a pattern the reader can already see (`// Same derivation as infra/main.bicep`);
- narrate the change (`// Added for #1408`, `// New param`).

When in doubt, leave it out. Before finishing, reread every comment you added and delete any that fail this test.
