import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";
import security from "eslint-plugin-security";
import sonarjs from "eslint-plugin-sonarjs";

export default defineConfig([
  ...nextVitals,
  ...nextTs,
  security.configs.recommended,
  {
    plugins: { sonarjs },
    rules: {
      complexity: ["error", 15],
      "max-lines-per-function": ["error", { max: 50, skipBlankLines: true, skipComments: true }],
      "max-params": ["error", 5],
      "max-depth": ["error", 3],
      "no-empty": "error",
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/no-floating-promises": "off",
      "sonarjs/cognitive-complexity": ["error", 15],
      "sonarjs/no-duplicate-string": "warn",
      "security/detect-object-injection": "off",
    },
  },
  globalIgnores([".next/**", "out/**", "build/**", "coverage/**", "next-env.d.ts"]),
]);
