#!/usr/bin/env node
'use strict';

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const args = process.argv.slice(2);

// Handle --help
if (args.includes('--help') || args.includes('-h')) {
  console.log(`
  Usage:
    npx design-driven-development <project-path>      Install into a project
    npx design-driven-development uninstall <path>    Remove from a project
    npx design-driven-development --help              Show this message
  `);
  process.exit(0);
}

const packageRoot = path.join(__dirname, '..');
const installScript = path.join(packageRoot, 'install.sh');
const uninstallScript = path.join(packageRoot, 'uninstall.sh');

if (args[0] === 'uninstall') {
  const projectPath = args[1] || process.cwd();
  execSync(`bash "${uninstallScript}" "${projectPath}"`, { stdio: 'inherit' });
} else {
  const projectPath = args[0] || process.cwd();
  if (!fs.existsSync(projectPath)) {
    console.error(`Error: path does not exist: ${projectPath}`);
    process.exit(1);
  }
  execSync(`bash "${installScript}" "${projectPath}"`, { stdio: 'inherit' });
}
