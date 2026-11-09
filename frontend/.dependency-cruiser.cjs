/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  forbidden: [
    { name: "no-circular", severity: "error", from: {}, to: { circular: true } },
    {
      name: "domain-no-framework",
      severity: "error",
      from: { path: "^src/domain" },
      to: { path: "node_modules/(next|react|react-dom)/" },
    },
    {
      name: "ui-no-infra",
      severity: "error",
      from: { path: "^src/(app|components)" },
      to: { path: "^src/infra" },
    },
  ],
  options: { tsConfig: { fileName: "tsconfig.json" }, doNotFollow: { path: "node_modules" } },
};
