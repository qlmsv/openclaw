import { defineConfig } from "tsdown";

const env = {
  NODE_ENV: "production",
};

function buildInputOptions(options: { onLog?: unknown; [key: string]: unknown }) {
  if (process.env.OPENCLAW_BUILD_VERBOSE === "1") {
    return undefined;
  }

  const previousOnLog = typeof options.onLog === "function" ? options.onLog : undefined;

  return {
    ...options,
    onLog(
      level: string,
      log: { code?: string },
      defaultHandler: (level: string, log: { code?: string }) => void,
    ) {
      if (log.code === "PLUGIN_TIMINGS") {
        return;
      }
      if (typeof previousOnLog === "function") {
        previousOnLog(level, log, defaultHandler);
        return;
      }
      defaultHandler(level, log);
    },
  };
}

function nodeBuildConfig(config: Record<string, unknown>) {
  return {
    ...config,
    env,
    fixedExtension: false,
    platform: "node",
    inputOptions: buildInputOptions,
  };
}

const pluginSdkEntrypoints = [
  "index",
  "core",
  "compat",
  "telegram",
  "discord",
  "slack",
  "signal",
  "imessage",
  "whatsapp",
  "line",
  "msteams",
  "acpx",
  "bluebubbles",
  "copilot-proxy",
  "device-pair",
  "diagnostics-otel",
  "diffs",
  "feishu",
  "google-gemini-cli-auth",
  "googlechat",
  "irc",
  "llm-task",
  "lobster",
  "matrix",
  "mattermost",
  "memory-core",
  "memory-lancedb",
  "minimax-portal-auth",
  "nextcloud-talk",
  "nostr",
  "open-prose",
  "phone-control",
  "qwen-portal-auth",
  "synology-chat",
  "talk-voice",
  "test-utils",
  "thread-ownership",
  "tlon",
  "twitch",
  "voice-call",
  "zalo",
  "zalouser",
  "account-id",
  "keyed-async-queue",
] as const;

const pluginSdkEntryGroups = [
  pluginSdkEntrypoints.slice(0, 12),
  pluginSdkEntrypoints.slice(12, 24),
  pluginSdkEntrypoints.slice(24, 36),
  pluginSdkEntrypoints.slice(36),
] as const;

export default defineConfig([
  nodeBuildConfig({
    name: "core-index",
    entry: "src/index.ts",
  }),
  nodeBuildConfig({
    name: "core-entry",
    entry: "src/entry.ts",
  }),
  nodeBuildConfig({
    name: "core-daemon-cli",
    // Ensure this module is bundled as an entry so legacy CLI shims can resolve its exports.
    entry: "src/cli/daemon-cli.ts",
  }),
  nodeBuildConfig({
    name: "core-warning-filter",
    entry: "src/infra/warning-filter.ts",
  }),
  nodeBuildConfig({
    name: "channels-runtime",
    // Keep sync lazy-runtime channel modules as concrete dist files.
    entry: {
      "channels/plugins/agent-tools/whatsapp-login":
        "src/channels/plugins/agent-tools/whatsapp-login.ts",
      "channels/plugins/actions/discord": "src/channels/plugins/actions/discord.ts",
      "channels/plugins/actions/signal": "src/channels/plugins/actions/signal.ts",
      "channels/plugins/actions/telegram": "src/channels/plugins/actions/telegram.ts",
      "telegram/audit": "src/telegram/audit.ts",
      "telegram/token": "src/telegram/token.ts",
      "line/accounts": "src/line/accounts.ts",
      "line/send": "src/line/send.ts",
      "line/template-messages": "src/line/template-messages.ts",
    },
  }),
  ...pluginSdkEntryGroups.flatMap((group, index) =>
    group.map((entry) =>
      nodeBuildConfig({
        name: `plugin-sdk-${index + 1}`,
        entry: `src/plugin-sdk/${entry}.ts`,
        outDir: "dist/plugin-sdk",
      }),
    ),
  ),
  nodeBuildConfig({
    name: "extension-api",
    entry: "src/extensionAPI.ts",
  }),
  nodeBuildConfig({
    name: "hooks",
    entry: ["src/hooks/bundled/*/handler.ts", "src/hooks/llm-slug-generator.ts"],
  }),
]);
