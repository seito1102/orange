import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        include: ['src/**/*.{test,spec}.ts'], // test または spec がファイル名に含まれるものを対象
        exclude: ['node_modules', 'dist'],   // node_modules や dist フォルダは除外
      },
});
