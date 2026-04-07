#!/usr/bin/env -S deno run --allow-run --allow-env --allow-read --allow-net

// ============================================================================
// Configuration
// ============================================================================

const config = {
  // Atlassian / Jira
  jira: {
    cloudId: "70d988ec-909e-40ed-b509-0e138ac896aa",
    email: "aliazhar.khan@omio.com",
    tokenEnvVar: "JIRA_CLI_TOKEN",
  },

  // Ticket matching pattern (regex)
  // Examples: "UP-1234", "PROJ-567", "ABC-89"
  ticketPattern: /UP-\d+/i,

  // Jira workflow transition names (adjust to match your workflow)
  transitions: {
    todo: "Backlog",           // Transition name that goes to "To Do"
    inProgress: "In Progress", // Transition name that goes to "In Progress"
    codeReview: "Code Review", // Transition name that goes to "Code Review"
  },

};

// ============================================================================

const JIRA_BASE_URL = `https://api.atlassian.com/ex/jira/${config.jira.cloudId}/rest/api/3`;

// Shell command helper with template strings
async function $(strings: TemplateStringsArray, ...values: unknown[]): Promise<string> {
  const cmd = strings.reduce((acc, str, i) => acc + str + (values[i] ?? ""), "");
  const parts = cmd.trim().split(/\s+/);

  const command = new Deno.Command(parts[0], {
    args: parts.slice(1),
    stdout: "piped",
    stderr: "piped",
  });

  const { stdout } = await command.output();
  return new TextDecoder().decode(stdout).trim();
}

// Check if command succeeds (for boolean checks)
async function $ok(strings: TemplateStringsArray, ...values: unknown[]): Promise<boolean> {
  const cmd = strings.reduce((acc, str, i) => acc + str + (values[i] ?? ""), "");
  const parts = cmd.trim().split(/\s+/);

  try {
    const command = new Deno.Command(parts[0], {
      args: parts.slice(1),
      stdout: "null",
      stderr: "null",
    });
    const { success } = await command.output();
    return success;
  } catch {
    return false;
  }
}

function extractTicketId(branchName: string): string | null {
  const match = branchName.match(config.ticketPattern);
  return match ? match[0].toUpperCase() : null;
}

function getAuthHeader(): string {
  const token = Deno.env.get(config.jira.tokenEnvVar);
  if (!token) {
    throw new Error(`No Jira token found. Set ${config.jira.tokenEnvVar} env var.`);
  }
  // Atlassian API tokens use Basic auth with email:token
  const credentials = btoa(`${config.jira.email}:${token}`);
  return `Basic ${credentials}`;
}

async function getTransitions(ticketId: string, authHeader: string): Promise<Array<{ id: string; name: string }>> {
  const response = await fetch(`${JIRA_BASE_URL}/issue/${ticketId}/transitions`, {
    headers: {
      Authorization: authHeader,
      "Content-Type": "application/json",
    },
  });

  if (!response.ok) return [];
  const data = await response.json();
  return data.transitions || [];
}

async function transitionTicket(ticketId: string, transitionName: string, authHeader: string): Promise<void> {
  const transitions = await getTransitions(ticketId, authHeader);

  if (transitions.length === 0) {
    console.log(`  ⚠ ${ticketId}: No transitions available (auth issue?)`);
    return;
  }

  const transition = transitions.find((t) => t.name.toLowerCase() === transitionName.toLowerCase());

  if (!transition) {
    console.log(`  ✓ ${ticketId} already in "${transitionName}"`);
    return;
  }

  const response = await fetch(`${JIRA_BASE_URL}/issue/${ticketId}/transitions`, {
    method: "POST",
    headers: {
      Authorization: authHeader,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ transition: { id: transition.id } }),
  });

  if (response.ok) {
    console.log(`  ✓ Moved ${ticketId} → "${transitionName}"`);
  } else {
    console.error(`  ✗ Failed to move ${ticketId}: ${response.status}`);
  }
}

async function main() {
  const isFileCheckout = Deno.args[2] === "0";
  if (isFileCheckout) Deno.exit(0);

  const prevBranch = await $`git rev-parse --abbrev-ref @{-1}`;
  const currBranch = await $`git rev-parse --abbrev-ref HEAD`;

  if (prevBranch === currBranch || currBranch === "HEAD") Deno.exit(0);

  console.log(`\n🔀 Branch: ${prevBranch || "(none)"} → ${currBranch}`);

  let authHeader: string;
  try {
    authHeader = getAuthHeader();
  } catch (error) {
    console.error((error as Error).message);
    Deno.exit(1);
  }

  // Handle PREVIOUS branch (moving away)
  const prevTicket = extractTicketId(prevBranch);
  if (prevTicket) {
    const hasPR = await $ok`gh pr view ${prevBranch} --json number`;
    await transitionTicket(prevTicket, hasPR ? config.transitions.codeReview : config.transitions.todo, authHeader);
  }

  // Handle CURRENT branch (moving to)
  const currTicket = extractTicketId(currBranch);
  if (currTicket) {
    await transitionTicket(currTicket, config.transitions.inProgress, authHeader);
  }
}

main();
