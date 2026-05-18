/**
 * Example TypeScript module for testing Emacs tree-sitter and eglot
 * with typescript-language-server.
 */

interface User {
  readonly id: number;
  name: string;
  email: string;
}

function createUser(id: number, name: string, email: string): User {
  return { id, name, email };
}

function greetUser(user: User): string {
  return `Hello, ${user.name} (${user.email})!`;
}

// Demonstrate generics and type narrowing
function findById<T extends { id: number }>(
  items: T[],
  id: number
): T | undefined {
  return items.find((item) => item.id === id);
}

// Main
const users: User[] = [
  createUser(1, "Alice", "alice@example.com"),
  createUser(2, "Bob", "bob@example.com"),
];

const found = findById(users, 1);
if (found) {
  console.log(greetUser(found));
}
